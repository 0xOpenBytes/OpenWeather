//
//  OpenWeather template generated by OpenBytes on 02/04/2023.
//
// Created by Ahmed Shendy.
//  FavoritesViewModelTests.swift
//

import Test
import XCTest
import CoreLocation
@testable import OpenWeather

final class FavoritesViewModelTests: XCTestCase {

    func testOnViewDidAppear_emptyFavorites() {
        let sut: FavoritesViewModel = .mock

        sut.onViewDidLoad()
    }

    func testOnViewDidAppear_twoFavorites() {

    }

    func testGetWeatherSummary() async throws {
        func testGetWeatherSummary(on sut: FavoritesViewModel, for locations: [CLLocation]) async throws {
            sut.getWeatherSummary(for: locations)

            try await Waiter(sut).wait(for: \.value.content.summaries) { summaries in
                summaries.count == locations.count
            }

            XCTAssertEqual(sut.content.summaries.count, locations.count)
        }

        let sut: FavoritesViewModel = .mock

        try await testGetWeatherSummary(on: sut, for: [.london, .cairo])
        try await testGetWeatherSummary(on: sut, for: [])
    }
}
