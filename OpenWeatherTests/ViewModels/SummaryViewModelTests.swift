//
//  OpenWeather template generated by OpenBytes on 02/04/2023.
//
// Created by Ahmed Shendy.
//  SummaryViewModelTests.swift
//

import Test
import XCTest
import CoreLocation
@testable import OpenWeather

final class SummaryViewModelTests: XCTestCase {

    func testGetWeatherSummary() async throws {
        let sut: SummaryViewModel = .mock

        try await testGetWeatherSummary(on: sut, for: [.london, .cairo])
        try await testGetWeatherSummary(on: sut, for: [])
    }

    private func testGetWeatherSummary(on sut: SummaryViewModel, for locations: [CLLocation]) async throws {
        sut.getWeatherSummary(for: locations)

        try await Waiter(sut).wait(for: \.value.content.summaries) { summaries in
            summaries.count == locations.count
        }

        XCTAssertEqual(sut.content.summaries.count, locations.count)
    }
}
