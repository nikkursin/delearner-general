// Keep the frontend session type separate from the backend's same-named DTO.
#include "Auth/DLAuthSessionStore.h"
#include "Managers/DLAppStateManager.h"
#include "Sync/DLSyncCoordinator.h"

bool saveClientSession(const QString& path, const QString& userId,
                       const QString& token, const QString& deviceId)
{
    DLAuthSession session;
    session.userId = userId;
    session.sessionToken = token;
    session.deviceId = deviceId;
    return DLAuthSessionStore(path).saveSuccessfulSession(session);
}

QObject* clientCoordinator(DLAppStateManager& manager)
{
    return manager.findChild<DLSyncCoordinator*>();
}
