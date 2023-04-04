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

    func testEmptyLocations() async throws {
        let locations: [CLLocation] = []
        let sut: SummaryViewModel = .mock
        let waiter: Waiter = .init(sut)

        sut.getWeatherSummary(for: [.london])

        try await waiter.wait(for: \.value.content.summaries) { summaries in
            summaries.isEmpty == false
        }

        sut.getWeatherSummary(for: locations)

        try await waiter.wait(for: \.value.content.summaries) { summaries in
            summaries.count == locations.count
        }

        XCTAssertEqual(sut.content.summaries.count, locations.count)
    }

    func testOneLocation_London() async throws {
        let locations: [CLLocation] = [.london]
        let sut: SummaryViewModel = .mock

        sut.getWeatherSummary(for: locations)

        try await Waiter(sut).wait(for: \.value.content.summaries) { summaries in
            summaries.count == locations.count
        }

        XCTAssertEqual(sut.content.summaries.count, locations.count)
    }

    func testFourLocations() async throws {
        let locations: [CLLocation] = [.london, .cairo, .newYork, .newZealand]
        let sut: SummaryViewModel = .mock

        sut.getWeatherSummary(for: locations)

        try await Waiter(sut).wait(for: \.value.content.summaries) { summaries in
            summaries.count == locations.count
        }

        XCTAssertEqual(sut.content.summaries.count, locations.count)
    }
}