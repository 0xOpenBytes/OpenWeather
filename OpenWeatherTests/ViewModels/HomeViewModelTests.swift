//
//  OpenWeather template generated by OpenBytes on 02/04/2023.
//
// Created by Ahmed Shendy.
//  HomeViewModelTests.swift
//

import XCTest
import Test
@testable import OpenWeather

final class HomeViewModelTests: XCTestCase {

    func testLondonLocationWeather() async throws {
        let sut: HomeViewModel = .mock

        sut.getWeather(for: .london)

        try await Waiter(sut).wait(for: \.value.content) { content in
            content == sut.expectedLondonContent
        }

        XCTAssertEqual(sut.content, sut.expectedLondonContent)
    }
}

private extension HomeViewModel {
    var expectedLondonContent: Content {
        let locationName = "London"
        let temperature = "\(Mock.londonWeather.currentTemperature.abbreviatedAsProvided)"
        let symbolName = "\(Mock.londonWeather.symbolName)"
        let realFeel = "\(Mock.londonWeather.realFeel.abbreviatedAsProvided)"
        let uv = "\(Mock.londonWeather.uv)"
        let windSpeed = "\(Mock.londonWeather.wind.speed.abbreviatedAsProvided)"

        return Content(
            locationName: locationName,
            temperature: temperature,
            symbolName: symbolName,
            realFeel: realFeel,
            uv: uv,
            windSpeed: windSpeed
        )
    }
}
