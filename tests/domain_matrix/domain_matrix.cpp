#include <QtTest>
#include <QFile>
#include <QHttpServer>
#include <QHttpServerRequest>
#include <QTcpServer>
#include <QScopeGuard>
#include <functional>
#include "Managers/DLAppStateManager.h"
#include <QJsonArray>
#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QTemporaryDir>
#include <QUuid>

#define DLAuthSession DLBackendMatrixAuthSession
#include "auth/DLAuthService.h"
#include "handlers/DLEventsCompatibilityHandler.h"
#include "handlers/DLDeviceHandler.h"
#include "persistence/DLDatabaseMigrator.h"
#include "persistence/DLRegisteredDeviceRepository.h"
#undef DLAuthSession
#include "Managers/DLDatabaseManager.h"
#include "Sync/DLBootstrapStateRestorer.h"
#include "Sync/DLRemoteChangeReconciler.h"

bool saveClientSession(const QString&, const QString&, const QString&, const QString&);
QObject* clientCoordinator(DLAppStateManager&);

class DomainMatrix : public QObject
{
    Q_OBJECT
private slots:
    void init();
    void cleanup();
    void authenticationAndDeviceLifecycle();
    void automaticTwoDeviceReconnect();
    void bootstrapRaceCatchUp();
    void legacyPartOfSpeechMigrationBootstrapsFreshClient();
    void wordGroupContract2Convergence();
    void lwwTombstoneAndBootstrap_data();
    void lwwTombstoneAndBootstrap();
private:
    QJsonObject mutation(const QString& type, const QString& operation, int day, int device);
    void push(const QJsonObject& event, const QString& winnerOperation, int winnerDay);
    void converge(const QString& type, bool deleted, int day);
    void openClient(int device);
    QVariantMap visibleState();
    QJsonObject fixture(const QString& type);

    QTemporaryDir temporary;
    QSqlDatabase backend;
    std::unique_ptr<DLAuthService> auth;
    std::unique_ptr<DLEventsCompatibilityHandler> handler;
    QString owner, authorization, matrixType;
    QStringList devices;
    QMap<QString, QJsonObject> fixtures;
    QMap<QString, QJsonObject> contract2Fixtures;
};

static QString timestamp(int day)
{
    return QStringLiteral("2026-02-%1T12:00:00Z").arg(day, 2, 10, QChar('0'));
}

void DomainMatrix::init()
{
    QVERIFY(temporary.isValid());
    backend = QSqlDatabase::addDatabase("QSQLITE", "domain-matrix-backend");
    backend.setDatabaseName(":memory:");
    QVERIFY(backend.open());
    DLDatabaseMigrator migrator;
    QVERIFY2(migrator.initializePostgresBaseline(backend), qPrintable(migrator.lastError()));
    auth = std::make_unique<DLAuthService>(backend);
    const auto registration = auth->registerEmailPassword("matrix@example.com", "matrix-password");
    QVERIFY2(registration.success, qPrintable(registration.errorMessage));
    owner = registration.userId;
    authorization = "Bearer " + registration.sessionToken;
    devices.clear();
    for (int i = 0; i < 3; ++i) {
        const auto id = QUuid::createUuid().toString(QUuid::WithoutBraces);
        devices.append(id);
        DLDeviceRegistrationService service(backend);
        DLDeviceHandler deviceHandler(auth.get(), &service);
        const auto response = deviceHandler.handleRegister(QJsonDocument(QJsonObject{
            {"deviceId", id}, {"displayName", "Matrix device"}}).toJson(), authorization);
        QCOMPARE(response.statusCode(), QHttpServerResponse::StatusCode::Created);
        const auto registered = QJsonDocument::fromJson(response.data()).object();
        QCOMPARE(registered.value("deviceId").toString(), id);
        QCOMPARE(registered.value("userId").toString(), owner);
        QCOMPARE(registered.value("lifecycleState").toString(), "active");
        QCOMPARE(registered.value("syncCursor").toInteger(), 0);
    }
    handler = std::make_unique<DLEventsCompatibilityHandler>(&backend, &backend, auth.get());
    fixtures.clear();
    contract2Fixtures.clear();
    for (const auto& name : {"word-and-group-events.json", "review-settings-and-tombstone-events.json"}) {
        const bool wordGroupFixture = QString::fromLatin1(name) == QStringLiteral("word-and-group-events.json");
        QFile file(QString::fromLatin1(wordGroupFixture ? V2_FIXTURE_DIR : V1_FIXTURE_DIR) + '/' + name);
        QVERIFY(file.open(QIODevice::ReadOnly));
        const auto document = QJsonDocument::fromJson(file.readAll());
        QVERIFY(document.isObject());
        for (const auto& value : document.object().value("fixtures").toArray()) {
            const auto event = value.toObject();
            if (wordGroupFixture)
                contract2Fixtures.insert(event.value("name").toString(), event);
            if (event.value("operation").toString() != "create")
                continue;
            if (!wordGroupFixture || event.value("name").toString() == "group_create_full_state_with_portable_icon"
                || event.value("name").toString() == "noun_create_with_four_groups")
                fixtures.insert(event.value("entityType").toString(), event);
        }
    }
    QCOMPARE(fixtures.size(), 4);
}

void DomainMatrix::cleanup()
{
    auto& client = DLDatabaseManager::instance();
    client.clearSyncContext();
    client.closeDatabase();
    for (int i = 0; i < 3; ++i)
        QFile::remove(temporary.filePath(QString::number(i) + ".sqlite"));
    handler.reset();
    auth.reset();
    backend.close();
    backend = {};
    QSqlDatabase::removeDatabase("domain-matrix-backend");
}

void DomainMatrix::authenticationAndDeviceLifecycle()
{
    using Status = QHttpServerResponse::StatusCode;
    const auto json = [](const QHttpServerResponse& response) {
        return QJsonDocument::fromJson(response.data()).object();
    };
    const auto body = [](const QJsonObject& event) {
        return QJsonDocument(QJsonObject{{"events", QJsonArray{event}}}).toJson();
    };
    DLDeviceRegistrationService service(backend);
    DLDeviceHandler deviceHandler(auth.get(), &service);
    DLRegisteredDeviceRepository repository(backend);
    const auto registrationBody = QJsonDocument(QJsonObject{
        {"deviceId", devices.first()}, {"displayName", "Same device"}}).toJson();
    QCOMPARE(repository.devicesForUser(owner).size(), 3);
    QCOMPARE(deviceHandler.handleRegister(registrationBody, authorization).statusCode(), Status::Ok);
    QCOMPARE(repository.devicesForUser(owner).size(), 3); // Resolve does not duplicate.

    const auto event = mutation("group", "create", 2, 0);
    const auto cursorBody = QJsonDocument(QJsonObject{
        {"deviceId", devices.first()}, {"consumedSequence", 0}}).toJson();
    for (const auto& session : {QString(), QString("Bearer invalid-session")}) {
        QCOMPARE(deviceHandler.handleRegister(registrationBody, session).statusCode(), Status::Unauthorized);
        QCOMPARE(handler->handleUpload(body(event), session).statusCode(), Status::Unauthorized);
        QCOMPARE(handler->handleDownload({{"after", "0"}}, session).statusCode(), Status::Unauthorized);
        QCOMPARE(handler->handleBootstrap(session).statusCode(), Status::Unauthorized);
        QCOMPARE(handler->handleCursorAdvance(cursorBody, session).statusCode(), Status::Unauthorized);
    }
    QCOMPARE(json(handler->handleDownload({{"after", "0"}}, authorization)).value("events").toArray().size(), 0);
    QCOMPARE(json(handler->handleBootstrap(authorization)).value("state").toObject().value("groups").toArray().size(), 0);

    const auto other = auth->registerEmailPassword("other@example.com", "other-password");
    QVERIFY2(other.success, qPrintable(other.errorMessage));
    const auto otherAuthorization = "Bearer " + other.sessionToken;
    const auto claim = deviceHandler.handleRegister(registrationBody, otherAuthorization);
    QCOMPARE(claim.statusCode(), Status::Conflict);
    QCOMPARE(json(claim).value("error").toString(), "device_claim_conflict");
    QCOMPARE(repository.devicesForUser(other.userId).size(), 0);
    const auto otherDevice = QUuid::createUuid().toString(QUuid::WithoutBraces);
    QCOMPARE(deviceHandler.handleRegister(QJsonDocument(QJsonObject{{"deviceId", otherDevice}}).toJson(),
                                         otherAuthorization).statusCode(), Status::Created);

    // A valid session cannot upload through another account's registered device.
    auto foreignDeviceEvent = event;
    auto payload = event.value("payload").toObject();
    payload.insert("ownerUserId", other.userId);
    foreignDeviceEvent.insert("payload", payload);
    const auto foreignUpload = handler->handleUpload(body(foreignDeviceEvent), otherAuthorization);
    QCOMPARE(foreignUpload.statusCode(), Status::Forbidden);
    QCOMPARE(json(foreignUpload).value("error").toString(), "device_not_registered");
    foreignDeviceEvent.insert("deviceId", otherDevice);
    foreignDeviceEvent.insert("payload", event.value("payload")); // Spoof owner with valid own device.
    const auto spoof = json(handler->handleUpload(body(foreignDeviceEvent), otherAuthorization));
    QCOMPARE(spoof.value("accepted").toArray().size(), 0);
    QCOMPARE(spoof.value("rejected").toArray().size(), 1);
    QCOMPARE(spoof.value("rejected").toArray().first().toObject().value("reason").toString(), "unauthorized_owner_user");

    push(event, "create", 2);
    const auto ownerPage = json(handler->handleDownload({{"after", "0"}}, authorization));
    QCOMPARE(ownerPage.value("events").toArray().size(), 1);
    QCOMPARE(json(handler->handleDownload({{"after", "0"}}, otherAuthorization)).value("events").toArray().size(), 0);
    QCOMPARE(json(handler->handleBootstrap(otherAuthorization)).value("state").toObject().value("groups").toArray().size(), 0);
    QCOMPARE(handler->handleDownload({{"after", "0"}}, otherAuthorization).statusCode(), Status::Ok);
    QCOMPARE(handler->handleBootstrap(otherAuthorization).statusCode(), Status::Ok);
    const auto originalState = json(handler->handleBootstrap(authorization)).value("state");
    QCOMPARE(originalState.toObject().value("groups").toArray().size(), 1);
    QCOMPARE(handler->handleCursorAdvance(cursorBody, otherAuthorization).statusCode(), Status::Forbidden);
    QCOMPARE(repository.deviceById(owner, devices.first())->syncCursor, 0);

    QVERIFY(repository.updateLifecycleState(owner, devices.first(), "revoked", timestamp(3), timestamp(3)));
    const auto revoked = handler->handleUpload(body(mutation("group", "update", 4, 0)), authorization);
    QCOMPARE(revoked.statusCode(), Status::Forbidden);
    QCOMPARE(json(revoked).value("error").toString(), "device_revoked");
    const auto revokedCursor = handler->handleCursorAdvance(cursorBody, authorization);
    QCOMPARE(revokedCursor.statusCode(), Status::Conflict);
    QCOMPARE(json(revokedCursor).value("error").toString(), "device_revoked");
    QCOMPARE(json(handler->handleBootstrap(authorization)).value("state"), originalState);
    QCOMPARE(json(handler->handleDownload({{"after", "0"}}, authorization)).value("events").toArray().size(), 1);
    push(mutation("group", "update", 5, 1), "update", 5);
    QCOMPARE(json(handler->handleDownload({{"after", "0"}}, authorization)).value("events").toArray().size(), 2);
    QCOMPARE(json(handler->handleDownload({{"after", "0"}}, otherAuthorization)).value("events").toArray().size(), 0);
}

void DomainMatrix::legacyPartOfSpeechMigrationBootstrapsFreshClient()
{
    const QString wordId = QStringLiteral("3f692bd1-bd88-43d6-a653-28330cdb8c77");
    QSqlQuery query(backend);
    QVERIFY(query.exec(QStringLiteral(
        "UPDATE schema_metadata SET minor_version = 3 WHERE schema_name = 'postgres'")));
    query.prepare(QStringLiteral(
        "INSERT INTO domain_words "
        "(id, owner_user_id, german_word, normalized_german_word, article, part_of_speech, "
        "native_translation, normalized_native_translation, created_at, updated_at) "
        "VALUES (?, ?, 'Legacy noun', 'legacy noun', 'die', 'Nomen', 'legacy translation', "
        "'legacy translation', '2026-02-01T12:00:00Z', '2026-02-01T12:00:00Z')"));
    query.addBindValue(wordId);
    query.addBindValue(owner);
    QVERIFY2(query.exec(), qPrintable(query.lastError().text()));

    DLDatabaseMigrator migrator;
    QVERIFY2(migrator.initializePostgresBaseline(backend), qPrintable(migrator.lastError()));
    QCOMPARE(migrator.currentPostgresVersion(backend).toString(), QStringLiteral("1.6"));

    const QHttpServerResponse bootstrap = handler->handleBootstrap(authorization);
    QCOMPARE(bootstrap.statusCode(), QHttpServerResponse::StatusCode::Ok);
    openClient(2);
    DLBootstrapStateRestorer restorer(DLDatabaseManager::instance());
    QString error;
    QVERIFY2(restorer.restoreFromJson(bootstrap.data(), &error), qPrintable(error));
    const QVariantMap restored = DLDatabaseManager::instance().selectOneRow(
        QStringLiteral("SELECT part_of_speech FROM words WHERE sync_id = :sync_id"),
        {{QStringLiteral(":sync_id"), wordId}});
    QVERIFY(!restored.isEmpty());
    QCOMPARE(restored.value(QStringLiteral("part_of_speech")).toString(), QStringLiteral("noun"));
    QCOMPARE(DLDatabaseManager::instance().selectInt(
                 QStringLiteral("SELECT COUNT(*) FROM sync_outbox_events")), 0);
}

QJsonObject DomainMatrix::fixture(const QString& type)
{
    return fixtures.value(type);
}

QJsonObject DomainMatrix::mutation(const QString& type, const QString& operation, int day, int device)
{
    const auto base = fixture(type);
    const auto id = base.value("entityId").toString();
    QJsonObject body = base.value("payload").toObject();
    if (operation == "delete") {
        body = {{"entity_type", type}, {"entity_id", id},
                {"updatedAt", timestamp(day)}, {"deletedAt", timestamp(day)}};
        if (type == "app_setting")
            body.insert("setting_key", base.value("payload").toObject().value("setting_key"));
    } else {
        body.insert("updated_at", timestamp(day));
        // Distinct full-state values reveal stale state even when row counts match.
        if (type == "group") body.insert("name", QString::number(day));
        if (type == "word") body.insert("notes", QString::number(day));
        if (type == "word_review_stats") body.insert("correct_answers", day);
        if (type == "app_setting") body.insert("setting_value", QString::number(day));
        if (type == "word")
            body.insert("group_ids", QJsonArray{fixture("group").value("entityId").toString()});
    }
    body.insert("ownerUserId", owner);
    return {{"eventId", QUuid::createUuid().toString(QUuid::WithoutBraces)},
            {"deviceId", devices.at(device)}, {"entityType", type}, {"entityId", id},
            {"operation", operation}, {"baseVersion", 0},
            {"occurredAt", QDateTime::fromString(timestamp(day), Qt::ISODate).toSecsSinceEpoch()},
            {operation == "delete" ? "tombstone" : "payload", body}};
}

void DomainMatrix::push(const QJsonObject& event, const QString& winnerOperation, int winnerDay)
{
    const auto response = handler->handleUpload(
        QJsonDocument(QJsonObject{{"events", QJsonArray{event}}}).toJson(), authorization);
    QCOMPARE(response.statusCode(), QHttpServerResponse::StatusCode::Ok);
    const auto result = QJsonDocument::fromJson(response.data()).object();
    QCOMPARE(result.value("rejected").toArray().size(), 0);
    QCOMPARE(result.value("accepted").toArray().size(), 1);
    const auto canonical = result.value("accepted").toArray().first().toObject().value("canonical").toObject();
    QCOMPARE(canonical.value("operation").toString(), winnerOperation);
    const bool deleted = winnerOperation == "delete";
    const auto body = canonical.value(deleted ? "tombstone" : "state").toObject();
    QCOMPARE(body.value(deleted ? "updatedAt" : "updated_at").toString(), timestamp(winnerDay));
    if (!deleted) {
        const QMap<QString, QString> fields{{"group", "name"}, {"word", "notes"},
            {"word_review_stats", "correct_answers"}, {"app_setting", "setting_value"}};
        QCOMPARE(body.value(fields.value(event.value("entityType").toString())).toVariant().toString(),
                 QString::number(winnerDay));
    }
}

void DomainMatrix::openClient(int device)
{
    auto& client = DLDatabaseManager::instance();
    client.closeDatabase();
    QVERIFY2(client.openDatabase(temporary.filePath(QString::number(device) + ".sqlite")),
             qPrintable(client.lastError()));
    client.setSyncContext(owner, devices.at(device));
}

QVariantMap DomainMatrix::visibleState()
{
    auto& client = DLDatabaseManager::instance();
    QVariantMap state;
    for (const auto& table : {"groups", "words", "word_review_stats", "account_learning_settings"}) {
        // Word application creates unsynced default review scaffolding locally.
        // Compare review state only in the row that actually publishes reviews.
        if (QString::fromLatin1(table) == "word_review_stats" && matrixType != "word_review_stats")
            continue;
        QString sql = "SELECT * FROM " + QString::fromLatin1(table);
        if (QString::fromLatin1(table) != "word_review_stats") sql += " WHERE deleted_at IS NULL";
        auto rows = client.selectRows(sql);
        for (auto& value : rows) {
            auto row = value.toMap();
            // SQLite surrogate keys may differ after bootstrap; compare UUIDs.
            row.remove("id");
            row.remove("word_id");
            row.remove("group_id");
            value = row;
        }
        state.insert(table, rows);
    }
    return state;
}

void DomainMatrix::converge(const QString& type, bool deleted, int day)
{
    QVariantMap expected;
    for (int device = 0; device < 2; ++device) {
        openClient(device);
        auto& client = DLDatabaseManager::instance();
        const auto download = handler->handleDownload({{"after", QString::number(client.remoteCursor())}}, authorization);
        QCOMPARE(download.statusCode(), QHttpServerResponse::StatusCode::Ok);
        DLRemoteChangeReconciler reconciler(client);
        QString error;
        const auto response = QJsonDocument::fromJson(download.data()).object().toVariantMap();
        QVERIFY2(reconciler.applyDownloadedEventsAndAdvanceCursor(response, &error), qPrintable(error));
        const auto current = visibleState();
        const QMap<QString, QString> tables{{"group", "groups"}, {"word", "words"},
            {"word_review_stats", "word_review_stats"}, {"app_setting", "account_learning_settings"}};
        const auto rows = current.value(tables.value(type)).toList();
        QCOMPARE(rows.size(), deleted ? 0 : 1);
        if (!deleted) {
            const auto row = rows.first().toMap();
            QCOMPARE(row.value("updated_at").toLongLong(),
                     QDateTime::fromString(timestamp(day), Qt::ISODate).toSecsSinceEpoch());
        }
        const auto wordRows = current.value("words").toList();
        if (!wordRows.isEmpty()) {
            const auto groupId = wordRows.first().toMap().value("group_sync_id").toString();
            if (type == "group" && deleted) QVERIFY(groupId.isEmpty());
            else QCOMPARE(groupId, fixture("group").value("entityId").toString());
        }
        QCOMPARE(client.selectRows("PRAGMA foreign_key_check").size(), 0);
        // Re-delivery of the same page must not mutate state or create an outbox.
        QVERIFY2(reconciler.applyDownloadedEventsAndAdvanceCursor(response, &error), qPrintable(error));
        QCOMPARE(visibleState(), current);
        QCOMPARE(client.selectInt("SELECT COUNT(*) FROM sync_outbox_events"), 0);
        const auto ack = handler->handleCursorAdvance(QJsonDocument(QJsonObject{
            {"deviceId", devices.at(device)}, {"consumedSequence", client.remoteCursor()}}).toJson(), authorization);
        QCOMPARE(ack.statusCode(), QHttpServerResponse::StatusCode::Ok);
        if (device == 0) expected = current;
        else QCOMPARE(current, expected);
    }
    // A clean third client consumes the actual server export, not a test-built payload.
    auto& client = DLDatabaseManager::instance();
    client.closeDatabase();
    QFile::remove(temporary.filePath("2.sqlite"));
    openClient(2);
    const auto bootstrap = handler->handleBootstrap(authorization);
    QCOMPARE(bootstrap.statusCode(), QHttpServerResponse::StatusCode::Ok);
    DLBootstrapStateRestorer restorer(client);
    QString error;
    QVERIFY2(restorer.restoreFromJson(bootstrap.data(), &error), qPrintable(error));
    QCOMPARE(visibleState(), expected);
    QCOMPARE(client.selectInt("SELECT COUNT(*) FROM sync_outbox_events"), 0);
    QCOMPARE(client.selectRows("PRAGMA foreign_key_check").size(), 0);
}

void DomainMatrix::lwwTombstoneAndBootstrap_data()
{
    QTest::addColumn<QString>("type");
    for (const auto& type : {"group", "word", "word_review_stats", "app_setting"})
        QTest::newRow(type) << QString::fromLatin1(type);
}

void DomainMatrix::lwwTombstoneAndBootstrap()
{
    QFETCH(QString, type);
    matrixType = type;
    push(mutation("group", "create", 2, 0), "create", 2);
    push(mutation("word", "create", 2, 0), "create", 2);
    if (type != "group" && type != "word") push(mutation(type, "create", 2, 0), "create", 2);
    converge(type, false, 2);
    push(mutation(type, "update", 4, 1), "update", 4);
    push(mutation(type, "update", 3, 0), "update", 4); // stale update loses
    push(mutation(type, "delete", 3, 0), "update", 4); // stale delete loses
    converge(type, false, 4);
    if (type == "group") {
        // Existing group-delete outbox behavior sends the related word unlink.
        auto unlink = mutation("word", "update", 5, 1);
        auto payload = unlink.value("payload").toObject();
        payload.insert("group_ids", QJsonArray{});
        unlink.insert("payload", payload);
        push(unlink, "update", 5);
    }
    const auto deletion = mutation(type, "delete", 6, 1);
    push(deletion, "delete", 6);
    converge(type, true, 6);
    push(mutation(type, "update", 5, 0), "delete", 6); // stale resurrection loses
    push(deletion, "delete", 6); // same event retry
    converge(type, true, 6);
    push(mutation(type, "update", 8, 0), "update", 8); // later valid resurrection
    if (type == "group") push(mutation("word", "update", 8, 0), "update", 8); // explicit reattach
    push(mutation(type, "delete", 7, 1), "update", 8); // late-arriving older delete loses
    converge(type, false, 8);
}

void DomainMatrix::wordGroupContract2Convergence()
{
    matrixType = "word";
    const auto runtimeEvent = [&](const QJsonObject& source, int day, int device) {
        QJsonObject event = source;
        event.insert("eventId", QUuid::createUuid().toString(QUuid::WithoutBraces));
        event.insert("deviceId", devices.at(device));
        event.insert("updatedAt", timestamp(day));
        event.insert("baseVersion", 0);
        event.insert("occurredAt", QDateTime::fromString(timestamp(day), Qt::ISODate).toSecsSinceEpoch());
        QJsonObject payload = event.value("payload").toObject();
        payload.insert("ownerUserId", owner);
        payload.insert("updated_at", timestamp(day));
        event.insert("payload", payload);
        return event;
    };
    const auto upload = [&](const QJsonObject& event) {
        const auto response = handler->handleUpload(
            QJsonDocument(QJsonObject{{"events", QJsonArray{event}}}).toJson(), authorization);
        return qMakePair(response.statusCode(), QJsonDocument::fromJson(response.data()).object());
    };
    const auto pullIntoClient = [&](int device, qint64 after) {
        openClient(device);
        auto& client = DLDatabaseManager::instance();
        const auto response = handler->handleDownload({{"after", QString::number(after)}}, authorization);
        QCOMPARE(response.statusCode(), QHttpServerResponse::StatusCode::Ok);
        QString error;
        DLRemoteChangeReconciler reconciler(client);
        QVERIFY2(reconciler.applyDownloadedEventsAndAdvanceCursor(
                     QJsonDocument::fromJson(response.data()).object().toVariantMap(), &error),
                 qPrintable(error));
    };
    const auto membershipCount = [&](const QString& wordId) {
        return DLDatabaseManager::instance().selectInt(QStringLiteral(
            "SELECT COUNT(*) FROM word_group_memberships m JOIN words w ON w.id=m.word_id WHERE w.sync_id=:id"),
            {{":id", wordId}});
    };
    const auto wordState = [&](const QString& wordId) {
        return DLDatabaseManager::instance().selectOneRow(QStringLiteral(R"(
            SELECT w.*, nf.plural_form, vf.praesens_third_person_form, vf.praeteritum_form,
                   vf.partizip_ii_form, af.positive_form, af.comparative_form, af.superlative_form
            FROM words w
            LEFT JOIN noun_forms nf ON nf.word_id=w.id
            LEFT JOIN verb_forms vf ON vf.word_id=w.id
            LEFT JOIN adjective_forms af ON af.word_id=w.id
            WHERE w.sync_id=:id AND w.deleted_at IS NULL
        )"), {{":id", wordId}});
    };
    const auto groupState = [&](const QString& groupId) {
        return DLDatabaseManager::instance().selectOneRow(
            "SELECT * FROM groups WHERE sync_id=:id AND deleted_at IS NULL", {{":id", groupId}});
    };

    const QJsonObject nounFixture = contract2Fixtures.value("noun_create_with_four_groups");
    const QJsonArray groupIds = nounFixture.value("payload").toObject().value("group_ids").toArray();
    QCOMPARE(groupIds.size(), 4);
    const QStringList iconKeys{"travel", "train", "book", "star"};
    for (int index = 0; index < groupIds.size(); ++index) {
        QJsonObject group = runtimeEvent(
            contract2Fixtures.value("group_create_full_state_with_portable_icon"), 2, 0);
        const QString groupId = groupIds.at(index).toString();
        group.insert("entityId", groupId);
        QJsonObject payload = group.value("payload").toObject();
        payload.insert("id", groupId);
        payload.insert("name", QStringLiteral("Group %1").arg(index + 1));
        payload.insert("icon_key", iconKeys.at(index));
        group.insert("payload", payload);
        const auto result = upload(group);
        QCOMPARE(result.first, QHttpServerResponse::StatusCode::Ok);
        QCOMPARE(result.second.value("rejected").toArray().size(), 0);
        QCOMPARE(result.second.value("accepted").toArray().size(), 1);
        QCOMPARE(result.second.value("accepted").toArray().first().toObject()
                     .value("canonical").toObject().value("state").toObject().value("icon_key").toString(),
                 iconKeys.at(index));
    }

    QStringList wordFixtureNames{
        "noun_create_with_four_groups",
        "verb_create_with_all_forms",
        "adjective_create_with_comparison",
        "adverb_create",
        "phrase_create_with_literal_translation",
    };
    QJsonObject nounEvent;
    qint64 nounSequence = 0;
    for (int index = 0; index < wordFixtureNames.size(); ++index) {
        QJsonObject event = runtimeEvent(contract2Fixtures.value(wordFixtureNames.at(index)), 3 + index, 0);
        const auto result = upload(event);
        QCOMPARE(result.first, QHttpServerResponse::StatusCode::Ok);
        QCOMPARE(result.second.value("rejected").toArray().size(), 0);
        QCOMPARE(result.second.value("accepted").toArray().size(), 1);
        const QJsonObject accepted = result.second.value("accepted").toArray().first().toObject();
        const QJsonObject canonical = accepted.value("canonical").toObject().value("state").toObject();
        QCOMPARE(canonical.value("id").toString(), event.value("entityId").toString());
        if (index == 0) {
            nounEvent = event;
            nounSequence = accepted.value("serverSequence").toInteger();
            QCOMPARE(canonical.value("group_ids").toArray().size(), 4);
            QCOMPARE(canonical.value("notes").toString(), "Common travel vocabulary.");
            QCOMPARE(canonical.value("plural_form").toString(), "Fahrkarten");
        }
    }

    const auto duplicate = upload(nounEvent);
    QCOMPARE(duplicate.first, QHttpServerResponse::StatusCode::Ok);
    QCOMPARE(duplicate.second.value("accepted").toArray().size(), 1);
    QCOMPARE(duplicate.second.value("accepted").toArray().first().toObject()
                 .value("serverSequence").toInteger(), nounSequence);
    QCOMPARE(QJsonDocument::fromJson(handler->handleDownload({{"after", "0"}}, authorization).data())
                 .object().value("events").toArray().size(), 9);

    pullIntoClient(0, 0);
    auto& client = DLDatabaseManager::instance();
    const QString nounId = nounEvent.value("entityId").toString();
    QCOMPARE(membershipCount(nounId), 4);
    QCOMPARE(wordState(nounId).value("plural_form").toString(), "Fahrkarten");
    const QString verbId = contract2Fixtures.value("verb_create_with_all_forms").value("entityId").toString();
    QCOMPARE(wordState(verbId).value("praesens_third_person_form").toString(), QString::fromUtf8("fährt"));
    QCOMPARE(wordState(verbId).value("praeteritum_form").toString(), "fuhr");
    QCOMPARE(wordState(verbId).value("partizip_ii_form").toString(), "gefahren");
    const QString adjectiveId = contract2Fixtures.value("adjective_create_with_comparison").value("entityId").toString();
    QCOMPARE(wordState(adjectiveId).value("comparative_form").toString(), "schneller");
    const QString phraseId = contract2Fixtures.value("phrase_create_with_literal_translation").value("entityId").toString();
    QCOMPARE(wordState(phraseId).value("literal_translation").toString(), "That is sausage to me.");

    openClient(2);
    QString error;
    DLBootstrapStateRestorer initialBootstrap(client);
    QVERIFY2(initialBootstrap.restoreFromJson(handler->handleBootstrap(authorization).data(), &error), qPrintable(error));
    QCOMPARE(membershipCount(nounId), 4);
    QCOMPARE(groupState(groupIds.at(1).toString()).value("icon_key").toString(), "train");

    // Every membership transition must agree on both incremental clients and a
    // newly bootstrapped client, including the exact surviving UUIDs.
    const auto verifyMemberships = [&](const QJsonArray& expected) {
        QStringList expectedIds;
        for (const auto& id : expected) expectedIds.append(id.toString());
        expectedIds.sort();
        for (int device = 0; device < 3; ++device) {
            openClient(device);
            if (device < 2) {
                pullIntoClient(device, client.remoteCursor());
            } else {
                DLBootstrapStateRestorer restorer(client);
                QVERIFY2(restorer.restoreFromJson(handler->handleBootstrap(authorization).data(), &error),
                         qPrintable(error));
            }
            QStringList actualIds;
            for (const auto& row : client.selectRows(R"(
                SELECT g.sync_id FROM word_group_memberships m
                JOIN words w ON w.id=m.word_id JOIN groups g ON g.id=m.group_id
                WHERE w.sync_id=:id ORDER BY g.sync_id
            )", {{":id", nounId}})) actualIds.append(row.toMap().value("sync_id").toString());
            QCOMPARE(actualIds, expectedIds);
            QVERIFY(!wordState(nounId).isEmpty());
            QCOMPARE(client.selectInt("SELECT COUNT(*) FROM sync_outbox_events"), 0);
            QCOMPARE(client.selectRows("PRAGMA foreign_key_check").size(), 0);
        }
    };
    QCOMPARE(membershipCount(verbId), 1);
    QCOMPARE(membershipCount(adjectiveId), 0);
    QCOMPARE(wordState(adjectiveId).value("positive_form").toString(), "schnell");
    QCOMPARE(wordState(adjectiveId).value("superlative_form").toString(), "am schnellsten");
    QCOMPARE(wordState(nounId).value("example_phrase_de").toString(),
             "Ich kaufe eine Fahrkarte nach Berlin.");
    QCOMPARE(wordState(nounId).value("example_phrase_native").toString(),
             "I am buying a ticket to Berlin.");
    verifyMemberships(groupIds);

    QJsonObject update = runtimeEvent(nounFixture, 10, 1);
    update.insert("operation", "update");
    QJsonObject updatePayload = update.value("payload").toObject();
    QJsonArray reversedGroups;
    for (qsizetype index = groupIds.size(); index > 0; --index)
        reversedGroups.append(groupIds.at(index - 1));
    updatePayload.insert("group_ids", reversedGroups);
    updatePayload.insert("notes", "Edited on device B");
    update.insert("payload", updatePayload);
    const auto updateResult = upload(update);
    QCOMPARE(updateResult.first, QHttpServerResponse::StatusCode::Ok);
    QCOMPARE(updateResult.second.value("accepted").toArray().size(), 1);
    QCOMPARE(updateResult.second.value("accepted").toArray().first().toObject()
                 .value("canonical").toObject().value("state").toObject().value("group_ids").toArray().size(), 4);

    pullIntoClient(0, client.remoteCursor());
    QCOMPARE(membershipCount(nounId), 4);
    QCOMPARE(wordState(nounId).value("notes").toString(), "Edited on device B");
    pullIntoClient(1, 0);
    QCOMPARE(membershipCount(nounId), 4);
    QCOMPARE(wordState(nounId).value("notes").toString(), "Edited on device B");

    // A real fifth owned group ensures rejection is about cardinality.
    const QString fifthId = QUuid::createUuid().toString(QUuid::WithoutBraces);
    auto fifthGroup = runtimeEvent(contract2Fixtures.value("group_create_full_state_with_portable_icon"), 11, 0);
    fifthGroup.insert("entityId", fifthId);
    auto fifthPayload = fifthGroup.value("payload").toObject();
    fifthPayload.insert("id", fifthId);
    fifthGroup.insert("payload", fifthPayload);
    QCOMPARE(upload(fifthGroup).second.value("accepted").toArray().size(), 1);
    auto invalid = runtimeEvent(update, 11, 1);
    auto invalidPayload = invalid.value("payload").toObject();
    auto fiveIds = groupIds;
    fiveIds.append(fifthId);
    invalidPayload.insert("group_ids", fiveIds);
    invalid.insert("payload", invalidPayload);
    const auto beforeRejection = handler->handleBootstrap(authorization).data();
    const auto rejected = upload(invalid);
    QCOMPARE(rejected.first, QHttpServerResponse::StatusCode::Ok);
    QCOMPARE(rejected.second.value("accepted").toArray().size(), 0);
    QCOMPARE(rejected.second.value("rejected").toArray().size(), 1);
    QCOMPARE(rejected.second.value("rejected").toArray().first().toObject().value("reason").toString(),
             "too_many_groups");
    QCOMPARE(handler->handleBootstrap(authorization).data(), beforeRejection);
    verifyMemberships(groupIds);

    QJsonObject deletion = mutation("group", "delete", 12, 1);
    deletion.insert("entityId", groupIds.first().toString());
    QJsonObject tombstone = deletion.value("tombstone").toObject();
    tombstone.insert("entity_id", groupIds.first().toString());
    deletion.insert("tombstone", tombstone);
    const auto deleteResult = upload(deletion);
    QCOMPARE(deleteResult.first, QHttpServerResponse::StatusCode::Ok);
    QCOMPARE(deleteResult.second.value("accepted").toArray().size(), 1);
    const qint64 deleteSequence = deleteResult.second.value("accepted").toArray().first().toObject()
                                      .value("serverSequence").toInteger();
    const auto duplicateDelete = upload(deletion);
    QCOMPARE(duplicateDelete.second.value("accepted").toArray().first().toObject()
                 .value("serverSequence").toInteger(), deleteSequence);

    for (int device = 0; device < 2; ++device) {
        openClient(device);
        const qint64 cursor = client.remoteCursor();
        pullIntoClient(device, cursor);
        QVERIFY(!wordState(nounId).isEmpty());
        QCOMPARE(membershipCount(nounId), 3);
    }
    client.closeDatabase();
    QFile::remove(temporary.filePath("2.sqlite"));
    openClient(2);
    DLBootstrapStateRestorer finalBootstrap(client);
    QVERIFY2(finalBootstrap.restoreFromJson(handler->handleBootstrap(authorization).data(), &error), qPrintable(error));
    QVERIFY(!wordState(nounId).isEmpty());
    QCOMPARE(membershipCount(nounId), 3);
    QCOMPARE(wordState(nounId).value("notes").toString(), "Edited on device B");
    QCOMPARE(client.selectRows("PRAGMA foreign_key_check").size(), 0);
    int day = 13;
    const QList<QJsonArray> transitions{
        {groupIds.at(1), groupIds.at(2)}, // remove one, retain the others
        {groupIds.at(2)},                // one group
        {groupIds.at(3)},                // move to a different group
        {},                             // no groups, word remains
    };
    for (const auto& ids : transitions) {
        auto change = runtimeEvent(update, day++, 1);
        auto payload = change.value("payload").toObject();
        payload.insert("group_ids", ids);
        change.insert("payload", payload);
        QCOMPARE(upload(change).second.value("accepted").toArray().size(), 1);
        verifyMemberships(ids);
    }
    const auto plural = runtimeEvent(contract2Fixtures.value("plural_only_noun_update_without_groups"), day, 0);
    QCOMPARE(upload(plural).second.value("accepted").toArray().size(), 1);
    verifyMemberships({});
    for (int device = 0; device < 3; ++device) {
        openClient(device);
        QCOMPARE(wordState(nounId).value("article").toString(), "plural_only");
        QVERIFY(wordState(nounId).value("plural_form").toString().isEmpty());
    }

}

void DomainMatrix::bootstrapRaceCatchUp()
{
    matrixType = "word_review_stats";
    for (const auto& type : {"group", "word", "word_review_stats", "app_setting"})
        push(mutation(type, "create", 2, 0), "create", 2);
    const auto snapshot = handler->handleBootstrap(authorization);
    QCOMPARE(snapshot.statusCode(), QHttpServerResponse::StatusCode::Ok);
    const auto sequence = QJsonDocument::fromJson(snapshot.data()).object().value("serverSequence").toInteger();
    QVERIFY(sequence > 0);

    // Another device commits after export but before the new client installs it.
    push(mutation("word", "update", 4, 0), "update", 4);
    push(mutation("app_setting", "delete", 5, 0), "delete", 5);
    openClient(1);
    auto& client = DLDatabaseManager::instance();
    DLBootstrapStateRestorer restorer(client);
    QString error;
    QVERIFY2(restorer.restoreFromJson(snapshot.data(), &error), qPrintable(error));
    QCOMPARE(client.remoteCursor(), sequence);
    QCOMPARE(client.selectOneRow("SELECT notes FROM words WHERE sync_id=:id", {{":id", fixture("word").value("entityId").toString()}}).value("notes").toString(), "2");
    const auto page = handler->handleDownload({{"after", QString::number(sequence)}}, authorization);
    QCOMPARE(page.statusCode(), QHttpServerResponse::StatusCode::Ok);
    const auto response = QJsonDocument::fromJson(page.data()).object();
    QCOMPARE(response.value("events").toArray().size(), 2);
    DLRemoteChangeReconciler reconciler(client);
    QVERIFY2(reconciler.applyDownloadedEventsAndAdvanceCursor(response.toVariantMap(), &error), qPrintable(error));
    QVERIFY(client.remoteCursor() > sequence);
    QCOMPARE(client.selectOneRow("SELECT notes FROM words WHERE sync_id=:id", {{":id", fixture("word").value("entityId").toString()}}).value("notes").toString(), "4");
    QCOMPARE(client.selectInt("SELECT COUNT(*) FROM account_learning_settings WHERE deleted_at IS NOT NULL"), 1);
    const auto expected = visibleState();
    QVERIFY2(reconciler.applyDownloadedEventsAndAdvanceCursor(response.toVariantMap(), &error), qPrintable(error));
    QCOMPARE(visibleState(), expected);
    QCOMPARE(client.selectInt("SELECT COUNT(*) FROM sync_outbox_events"), 0);
    QCOMPARE(client.selectRows("PRAGMA foreign_key_check").size(), 0);
    const auto ack = handler->handleCursorAdvance(QJsonDocument(QJsonObject{
        {"deviceId", devices.at(1)}, {"consumedSequence", client.remoteCursor()}}).toJson(), authorization);
    QCOMPARE(ack.statusCode(), QHttpServerResponse::StatusCode::Ok);
    DLRegisteredDeviceRepository repository(backend);
    QCOMPARE(repository.deviceById(owner, devices.at(1))->syncCursor, client.remoteCursor());

    openClient(2);
    DLBootstrapStateRestorer fresh(client);
    QVERIFY2(fresh.restoreFromJson(handler->handleBootstrap(authorization).data(), &error), qPrintable(error));
    QCOMPARE(visibleState(), expected);
    QCOMPARE(client.selectRows("PRAGMA foreign_key_check").size(), 0);
}

void DomainMatrix::automaticTwoDeviceReconnect()
{
    QHttpServer server;
    QTcpServer listener;
    QVERIFY(listener.listen(QHostAddress::LocalHost));
    server.bind(&listener);
    bool failAcknowledgement = true;
    QList<QJsonObject> uploads;
    server.route("/events", QHttpServerRequest::Method::Post,
                 [&](const QHttpServerRequest& request) {
        uploads.append(QJsonDocument::fromJson(request.body()).object());
        auto response = handler->handleUpload(request.body(), request.value("Authorization"));
        if (failAcknowledgement) {
            failAcknowledgement = false;
            // The commit succeeded, but the client receives no usable acknowledgement.
            return QHttpServerResponse(QHttpServerResponse::StatusCode::ServiceUnavailable);
        }
        return response;
    });
    server.route("/events", QHttpServerRequest::Method::Get,
                 [&](const QHttpServerRequest& request) {
        return handler->handleDownload(request.query().queryItems(), request.value("Authorization"));
    });
    server.route("/events/cursor", QHttpServerRequest::Method::Post,
                 [&](const QHttpServerRequest& request) {
        return handler->handleCursorAdvance(request.body(), request.value("Authorization"));
    });
    const auto previousUrl = qgetenv("DELEARNER_API_BASE_URL");
    const bool hadUrl = qEnvironmentVariableIsSet("DELEARNER_API_BASE_URL");
    const auto restoreEnvironment = qScopeGuard([&] {
        if (hadUrl) qputenv("DELEARNER_API_BASE_URL", previousUrl);
        else qunsetenv("DELEARNER_API_BASE_URL");
    });
    qputenv("DELEARNER_API_BASE_URL",
            QString("http://127.0.0.1:%1").arg(listener.serverPort()).toUtf8());
    for (int device = 0; device < 2; ++device) {
        openClient(device);
        DLDatabaseManager::instance().closeDatabase();
        QVERIFY(saveClientSession(temporary.filePath(QString::number(device) + ".sqlite.auth.json"),
                                  owner, authorization.mid(7), devices.at(device)));
    }
    auto& client = DLDatabaseManager::instance();
    QString groupId;
    QVariantMap expected;
    // Fixed test timestamps keep conflict order independent of wall-clock speed.
    const auto datePending = [&](int day) {
        const auto pending = client.selectRows("SELECT event_id, envelope_json FROM sync_outbox_events");
        QCOMPARE(pending.size(), 1);
        auto row = pending.first().toMap();
        auto event = QJsonDocument::fromJson(row.value("envelope_json").toString().toUtf8()).object();
        const bool deleted = event.value("operation") == "delete";
        const QString key = deleted ? "tombstone" : "payload";
        auto payload = event.value(key).toObject();
        payload.insert(deleted ? "updatedAt" : "updated_at", timestamp(day));
        if (deleted) payload.insert("deletedAt", timestamp(day));
        event.insert(key, payload);
        event.insert("updatedAt", timestamp(day));
        const auto seconds = QDateTime::fromString(timestamp(day), Qt::ISODate).toSecsSinceEpoch();
        event.insert("occurredAt", seconds);
        QVERIFY(client.executeSql("UPDATE sync_outbox_events SET updated_at=:time, envelope_json=:event, "
                                  "payload_json=:payload, next_attempt_after=NULL",
            {{":time", seconds}, {":event", QString::fromUtf8(QJsonDocument(event).toJson(QJsonDocument::Compact))},
             {":payload", QString::fromUtf8(QJsonDocument(payload).toJson(QJsonDocument::Compact))}}));
        QVERIFY(client.executeSql("UPDATE groups SET updated_at=:time WHERE sync_id=:id",
                                  {{":time", seconds}, {":id", groupId}}));
    };
    const auto visit = [&](int device, const std::function<void(DLAppStateManager&)>& edit,
                           bool reconnect, bool success = true) {
        DLAppStateManager manager;
        manager.setNetworkAvailable(false);
        manager.init(temporary.filePath(QString::number(device) + ".sqlite"));
        QVERIFY(manager.currentScreen() != DLAppStateManager::AuthPage);
        QVERIFY(manager.currentScreen() != DLAppStateManager::StartupLoadingPage);
        auto* coordinator = clientCoordinator(manager);
        QVERIFY(coordinator);
        QSignalSpy finished(coordinator, SIGNAL(syncFinished(bool)));
        QVERIFY(finished.isValid());
        const auto uploadCount = uploads.size();
        edit(manager);
        QCoreApplication::processEvents();
        QCOMPARE(uploads.size(), uploadCount);
        QCOMPARE(finished.size(), 0); // Offline edits never initiate network sync.
        if (reconnect) {
            manager.setNetworkAvailable(true); // No manual sync or direct coordinator call.
            QTRY_COMPARE(finished.size(), 1);
            QCOMPARE(finished.first().first().toBool(), success);
            QVERIFY(!coordinator->property("syncInProgress").toBool());
            if (success) {
                QCOMPARE(client.selectInt("SELECT COUNT(*) FROM sync_outbox_events"), 0);
                DLRegisteredDeviceRepository repository(backend);
                QCOMPARE(repository.deviceById(owner, devices.at(device))->syncCursor, client.remoteCursor());
                QCOMPARE(client.selectRows("PRAGMA foreign_key_check").size(), 0);
            }
        }
        expected = client.fetchGroupById(groupId);
    };
    visit(0, [&](DLAppStateManager& manager) {
        groupId = manager.createGroup("Offline A");
        QVERIFY(!groupId.isEmpty());
        QCOMPARE(manager.groupCount(), 1);
        QCOMPARE(client.selectInt("SELECT COUNT(*) FROM sync_outbox_events"), 1);
        datePending(2);
    }, true, false);
    QCOMPARE(uploads.size(), 1);
    const auto committed = QJsonDocument::fromJson(handler->handleDownload({{"after", "0"}}, authorization).data()).object();
    QCOMPARE(committed.value("events").toArray().size(), 1);
    visit(0, [&](DLAppStateManager&) {
        QCOMPARE(client.selectInt("SELECT COUNT(*) FROM sync_outbox_events"), 1);
        // Make the persisted retry due without depending on a production backoff duration.
        QVERIFY(client.executeSql("UPDATE sync_outbox_events SET next_attempt_after=NULL"));
    }, true);
    QCOMPARE(uploads.size(), 2);
    QCOMPARE(uploads.at(0), uploads.at(1)); // Stable event ID and full payload across restart/retry.
    const auto retried = QJsonDocument::fromJson(handler->handleDownload({{"after", "0"}}, authorization).data()).object();
    QCOMPARE(retried.value("events"), committed.value("events"));
    QCOMPARE(retried.value("nextSequence"), committed.value("nextSequence"));
    visit(1, [](DLAppStateManager&) {}, true);
    QCOMPARE(expected.value("name").toString(), "Offline A");
    visit(1, [&](DLAppStateManager& manager) {
        QVERIFY(manager.updateGroup(groupId, "Older offline B"));
        datePending(4);
    }, false); // Persist offline work while A makes a newer edit.
    QCOMPARE(expected.value("name").toString(), "Older offline B");
    visit(0, [&](DLAppStateManager& manager) {
        QVERIFY(manager.updateGroup(groupId, "Newer A"));
        datePending(6);
    }, true);
    const auto newer = expected;
    visit(1, [](DLAppStateManager&) {}, true);
    QCOMPARE(expected, newer); // Canonical acknowledgement silently replaces optimistic B.
    visit(1, [&](DLAppStateManager& manager) {
        QVERIFY(manager.deleteGroup(groupId));
        QCOMPARE(manager.groupCount(), 0);
        datePending(8);
    }, true);
    QVERIFY(expected.isEmpty());
    visit(0, [](DLAppStateManager&) {}, true);
    QVERIFY(expected.isEmpty()); // B's tombstone reaches A automatically on reconnect.
    openClient(0);
    QCOMPARE(client.selectInt("SELECT COUNT(*) FROM groups WHERE deleted_at IS NOT NULL"), 1);
    openClient(1);
    QCOMPARE(client.selectInt("SELECT COUNT(*) FROM groups WHERE deleted_at IS NOT NULL"), 1);
}

QTEST_GUILESS_MAIN(DomainMatrix)
#include "domain_matrix.moc"
