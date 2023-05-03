//
//  OpenWeather template generated by OpenBytes on 30/04/2023.
//
// Created by Ahmed Shendy.
//  DatabaseServiceTests.swift
//

import XCTest
@testable import OpenWeather

final class DatabaseServiceTests: XCTestCase {
    func testFavoritesSchema() async throws {
        let sut: DatabaseService = try SQLiteDatabaseService.empty()

        let tableName: String = "favorites"
        let tableExists = try await sut.tableExists(tableName)

        XCTAssert(tableExists)

        let columns = try await sut.columns(in: tableName)

        XCTAssertEqual(columns, ["id", "name", "lat", "long"])
    }

    func testInsertFavoriteLocation() async throws {
        let sut: DatabaseService = try SQLiteDatabaseService.empty()

        let location: LocationData = .init(
            name: "London",
            location: .london
        )

        let locationDoesNotExist = try await sut.favoriteExists(location) == false

        XCTAssert(locationDoesNotExist)

        try await sut.insertFavoriteLocation(location)

        let foundLocation = try await sut.findFavoriteLocation(location)

        XCTAssert(location == foundLocation)
    }

    func testRemoveFavoriteLocation() async throws {
        let sut: DatabaseService = try SQLiteDatabaseService.empty()

        let location: LocationData = .init(
            name: "London",
            location: .london
        )

        try await sut.insertFavoriteLocation(location)

        let locationExists = try await sut.favoriteExists(location)

        XCTAssert(locationExists)

        try await sut.deleteFavoriteLocation(location)

        let locationDoesNotExist = try await sut.favoriteExists(location) == false

        XCTAssert(locationDoesNotExist)
    }
}