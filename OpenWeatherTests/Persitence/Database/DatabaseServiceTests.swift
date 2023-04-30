//
//  OpenWeather template generated by OpenBytes on 30/04/2023.
//
// Created by Ahmed Shendy.
//  DatabaseServiceTests.swift
//

import XCTest
@testable import OpenWeather

final class DatabaseServiceTests: XCTestCase {
    func testDatabaseSchema() async throws {
        let sut: DatabaseService = try SQLiteDatabaseService.empty()

        let tableExists = try await sut.tableExists("favorites")

        XCTAssert(tableExists)
    }

    func testInsertFavoriteLocation() async throws {
        let sut: DatabaseService = try SQLiteDatabaseService.empty()

        let location: LocationData = .init(
            name: "London",
            location: .london
        )

        let locationDoesNotExist = try await sut.favoriteExists(
            by: location.id.uuidString
        ) == false

        XCTAssert(locationDoesNotExist)

        try await sut.saveFavoriteLocation(location)

        let foundLocation = try await sut.findFavoriteLocation(
            by: location.id.uuidString
        )

        XCTAssert(location == foundLocation)
    }
}
