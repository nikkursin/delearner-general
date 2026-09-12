#include <QtTest>
#include <QFile>
#include <QJsonArray>
#include <QSqlDatabase>
#include <QTemporaryDir>
#include <QUuid>

#include "auth/DLAuthService.h"
#include "handlers/DLEventsCompatibilityHandler.h"
#include "handlers/DLDeviceHandler.h"
#include "persistence/DLDatabaseMigrator.h"
#include "persistence/DLRegisteredDeviceRepository.h"
#include "Managers/DLDatabaseManager.h"
#include "Sync/DLBootstrapStateRestorer.h"
#include "Sync/DLRemoteChangeReconciler.h"

class DomainMatrix : public QObject
{
    Q_OBJECT
private slots:
    void init();
    void cleanup();
    void authenticationAndDeviceLifecycle();
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
    for (const auto& name : {"word-and-group-events.json", "review-settings-and-tombstone-events.json"}) {
        QFile file(QStringLiteral(FIXTURE_DIR) + '/' + name);
        QVERIFY(file.open(QIODevice::ReadOnly));
        const auto document = QJsonDocument::fromJson(file.readAll());
        QVERIFY(document.isObject());
        for (const auto& value : document.object().value("fixtures").toArray()) {
            const auto event = value.toObject();
            if (event.value("operation").toString() == "create")
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
        payload.insert("group_id", QJsonValue::Null);
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

QTEST_GUILESS_MAIN(DomainMatrix)
#include "domain_matrix.moc"
