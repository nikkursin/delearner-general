cmake_minimum_required(VERSION 3.21)
project(DElearnerDomainMatrix LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
find_package(Qt6 REQUIRED COMPONENTS Core Sql Network HttpServer Test)
get_filename_component(DELEARNER_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../.." ABSOLUTE)

# Reuse the client library through its owning project, with no application/UI.
set(DELEARNER_BUILD_APP OFF CACHE BOOL "" FORCE)
set(DELEARNER_BUILD_TESTS OFF CACHE BOOL "" FORCE)
add_subdirectory("${DELEARNER_ROOT}/delearner-frontend" frontend EXCLUDE_FROM_ALL)

# The backend currently exposes an executable, not a linkable library. Compile
# only its production handler dependency closure for this cross-repo test.
set(BACKEND "${DELEARNER_ROOT}/delearner-backend/src")
add_executable(domain_matrix
    domain_matrix.cpp
    ${BACKEND}/auth/DLAuthService.cpp
    ${BACKEND}/auth/DLAuthSessionRepository.cpp
    ${BACKEND}/auth/DLPasswordHasher.cpp
    ${BACKEND}/common/DLJsonResponse.cpp
    ${BACKEND}/devices/DLDeviceRegistrationService.cpp
    ${BACKEND}/handlers/DLDeviceHandler.cpp
    ${BACKEND}/domain/DLEventBatch.cpp
    ${BACKEND}/domain/DLSyncEnums.cpp
    ${BACKEND}/domain/DLSyncEvent.cpp
    ${BACKEND}/events/DLConflictResolver.cpp
    ${BACKEND}/handlers/DLEventsCompatibilityHandler.cpp
    ${BACKEND}/persistence/DLAuthIdentityRepository.cpp
    ${BACKEND}/persistence/DLDatabaseMigrator.cpp
    ${BACKEND}/persistence/DLDatabaseSchemaVersion.cpp
    ${BACKEND}/persistence/DLDomainRepository.cpp
    ${BACKEND}/persistence/DLPostgresConnectionSettings.cpp
    ${BACKEND}/persistence/DLRegisteredDeviceRepository.cpp
    ${BACKEND}/persistence/DLSyncTransactionRepository.cpp
)
target_include_directories(domain_matrix PRIVATE "${BACKEND}")
target_compile_definitions(domain_matrix PRIVATE FIXTURE_DIR="${DELEARNER_ROOT}/contracts/fixtures/v1")
target_link_libraries(domain_matrix PRIVATE delearner_core Qt6::HttpServer Qt6::Test)
enable_testing()
add_test(NAME authentication_device_lifecycle COMMAND domain_matrix authenticationAndDeviceLifecycle)
add_test(NAME domain_relationship_tombstone_matrix COMMAND domain_matrix lwwTombstoneAndBootstrap)
