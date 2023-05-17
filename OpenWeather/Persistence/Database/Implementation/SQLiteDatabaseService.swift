//
//  OpenWeather template generated by OpenBytes on 30/04/2023.
//
// Created by Ahmed Shendy.
//  SQLiteDatabaseService.swift
//

import GRDB
import os.log
import Combine
import Foundation

struct SQLiteDatabaseService: DatabaseService {
    private let dbQueue: any DatabaseWriter

    init(_ dbQueue: any DatabaseWriter) throws {
        self.dbQueue = dbQueue

        try self.migrator.migrate(dbQueue)
    }

    func tableExists(_ name: String) async throws -> Bool {
        try await dbQueue.read { db in
            try db.tableExists(name)
        }
    }

    func columns(in name: String) async throws -> [String] {
        try await dbQueue.read { db in
            try db
                .columns(in: name)
                .map { $0.name }
        }
    }

    func favoriteExists(_ location: DeviceLocation) async throws -> Bool {
        try await dbQueue.read { db in
            guard let count = try Int.fetchOne(
                db,
                sql: "SELECT COUNT(*) FROM favorites WHERE name=? and lat=? and long=?",
                arguments: [
                    location.name,
                    location.latitude,
                    location.longitude
                ]
            )
            else { return false }

            return count == 1
        }
    }

    func fetchOneFavorite(_ location: DeviceLocation) async throws -> DeviceLocation? {
        try await dbQueue.read { db in
            guard let row = try Row.fetchOne(
                db,
                sql: "SELECT name, lat, long FROM favorites WHERE name=? and lat=? and long=? LIMIT 1",
                arguments: [
                    location.name,
                    location.latitude,
                    location.longitude
                ]
            )
            else { return nil }

            return try LocationAdapter.device(from: row)
        }
    }

    func fetchAllFavorites() async throws -> [DeviceLocation] {
        try await dbQueue.read { db in
            try fetchAllFavorites(db: db)
        }
    }

    func fetchAllFavoritesPublisher() -> AnyPublisher<[DeviceLocation], Error> {
        ValueObservation.tracking { db in
            try fetchAllFavorites(db: db)
        }
        .publisher(in: dbQueue)
        .eraseToAnyPublisher()
    }

    private func fetchAllFavorites(db: Database) throws -> [DeviceLocation] {
        let rows = try Row.fetchAll(
            db,
            sql: "SELECT name, lat, long FROM favorites ORDER BY created_at DESC"
        )

        return try rows.compactMap {
            try LocationAdapter.device(from: $0)
        }
    }

    func fetchAllFavorites(matching locations: [DeviceLocation]) async throws -> [DeviceLocation] {
        try await dbQueue.read { db in

            let arguments = locations.reduce(
                into: (names: [String](), lats: [Double](), longs: [Double]())
            ) { partialResult, location in
                partialResult.names.append(location.name)
                partialResult.lats.append(location.latitude)
                partialResult.longs.append(location.longitude)
            }

            let request: SQLRequest<LocationData> = """
                SELECT name, lat, long FROM favorites
                WHERE name IN \(arguments.names)
                AND lat IN \(arguments.lats)
                AND long IN \(arguments.longs)
                """

            return try request
                .fetchAll(db)
                .mapToDevice()
        }
    }

    func insertOneFavorite(_ location: DeviceLocation) async throws {
        try await dbQueue.write { db in
            try db.execute(
                sql: "INSERT INTO favorites (name, lat, long) VALUES (?, ?, ?)",
                arguments: [
                    location.name,
                    location.latitude,
                    location.longitude
                ]
            )
        }
    }

    func deleteOneFavorite(_ location: DeviceLocation) async throws {
        try await dbQueue.write { db in
            try db.execute(
                sql: "DELETE FROM favorites WHERE name=? and lat=? and long=?",
                arguments: [
                    location.name,
                    location.latitude,
                    location.longitude
                ]
            )
        }
    }
}

extension SQLiteDatabaseService {
    /// The database for the application
    static let shared = makeShared()

    private static func makeShared() -> SQLiteDatabaseService {
        do {
            // Apply recommendations from
            // <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/databaseconnections>
            //
            // Create the "Application Support/Database" directory if needed
            let fileManager = FileManager.default
            let appSupportURL = try fileManager.url(
                for: .applicationSupportDirectory, in: .userDomainMask,
                appropriateFor: nil, create: true)
            let directoryURL = appSupportURL.appendingPathComponent("Database", isDirectory: true)

            // Support for tests: delete the database if requested
            if CommandLine.arguments.contains("-reset") {
                try? fileManager.removeItem(at: directoryURL)
            }

            // Create the database folder if needed
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)

            // Open or create the database
            let databaseURL = directoryURL.appendingPathComponent("db.sqlite")
            NSLog("Database stored at \(databaseURL.path)")
            let dbPool = try DatabasePool(
                path: databaseURL.path,
                // Use default AppDatabase configuration
                configuration: SQLiteDatabaseService.makeConfiguration()
            )

            return try SQLiteDatabaseService(dbPool)
        } catch {
            // TODO: I think we should handle this in better way
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            //
            // Typical reasons for an error here include:
            // * The parent directory cannot be created, or disallows writing.
            // * The database is not accessible, due to permissions
            //   or data protection when the device is locked.
            // * The device is out of space.
            // * The database could not be migrated to its latest schema version.
            // Check the error message to determine what the actual problem was.
            fatalError("Unresolved error \(error)")
        }
    }
}

extension SQLiteDatabaseService {
    private static let sqlLogger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "SQL")

    /// Returns a database configuration suited for `PlayerRepository`.
    ///
    /// SQL statements are logged if the `SQL_TRACE` environment variable
    /// is set.
    ///
    /// - parameter base: A base configuration.
    public static func makeConfiguration(_ base: Configuration = Configuration()) -> Configuration {
        var config = base

        // An opportunity to add required custom SQL functions or
        // collations, if needed:
        // config.prepareDatabase { db in
        //     db.add(function: ...)
        // }

        // Log SQL statements if the `SQL_TRACE` environment variable is set.
        // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/database/trace(options:_:)>
        if ProcessInfo.processInfo.environment["SQL_TRACE"] != nil {
            config.prepareDatabase { db in
                db.trace {
                    // It's ok to log statements publicly. Sensitive
                    // information (statement arguments) are not logged
                    // unless config.publicStatementArguments is set
                    // (see below).
                    os_log("%{public}@", log: sqlLogger, type: .debug, String(describing: $0))
                }
            }
        }

#if DEBUG
        // Protect sensitive information by enabling verbose debugging in
        // DEBUG builds only.
        // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/configuration/publicstatementarguments>
        config.publicStatementArguments = true
#endif

        return config
    }
}

extension SQLiteDatabaseService {
    /// The DatabaseMigrator that defines the database schema.
    ///
    /// See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/migrations>
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

#if DEBUG
        // Speed up development by nuking the database when migrations change
        // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/migrations>
        migrator.eraseDatabaseOnSchemaChange = true
#endif

        migrator.registerMigration("createFavorites") { db in
            // Create a table
            // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/databaseschema>
            try db.create(table: "favorites") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull()
                t.column("lat", .double).notNull()
                t.column("long", .double).notNull()
                t.column("created_at", .datetime).defaults(sql: "current_timestamp")
            }
        }

        // Migrations for future application versions will be inserted here:
        // migrator.registerMigration(...) { db in
        //     ...
        // }

        return migrator
    }
}

final class MockDatabaseService: DatabaseService {
    private var favorites: [LocationData]

    init(favorites: [LocationData] = []) {
        self.favorites = favorites
    }

    func tableExists(_ name: String) async throws -> Bool {
        true
    }

    func columns(in name: String) async throws -> [String] {
        ["id", "name", "lat", "long", "created_at"]
    }

    func favoriteExists(_ location: DeviceLocation) async throws -> Bool {
        try await fetchOneFavorite(location) != nil
    }

    func fetchOneFavorite(_ location: DeviceLocation) async throws -> DeviceLocation? {
        favorites
            .first(where: { $0 == location })
            .map { LocationAdapter.device(from: $0) }
    }

    func fetchAllFavorites() async throws -> [DeviceLocation] {
        fetchAllFavorites(db: favorites)
    }

    func fetchAllFavoritesPublisher() -> AnyPublisher<[DeviceLocation], Error> {
        fetchAllFavorites(db: favorites)
            .publisher
            .collect()
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    private func fetchAllFavorites(db: [LocationData]) -> [DeviceLocation] {
        db.map { LocationAdapter.device(from: $0) }
    }

    func fetchAllFavorites(matching locations: [DeviceLocation]) async throws -> [DeviceLocation] {
        return locations.filter { deviceLocation in
            favorites.contains(where: { locationData in
                deviceLocation.name == locationData.name
                && deviceLocation.latitude == locationData.lat
                && deviceLocation.longitude == locationData.long
            })
        }
    }

    func insertOneFavorite(_ location: DeviceLocation) async throws {
        favorites.append(LocationAdapter.data(from: location))
    }

    func deleteOneFavorite(_ location: DeviceLocation) async throws {
        favorites.removeAll(where: { $0 == location })
    }
}
