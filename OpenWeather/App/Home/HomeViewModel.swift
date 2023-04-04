//
//  OpenWeather template generated by OpenBytes on 15/03/2023.
//
// Created by Ahmed Shendy.
//  HomeViewModel.swift
//

import Foundation
import ViewModel
import CoreLocation

final class HomeViewModel: ViewModel<HomeViewModel.Capabilities, HomeViewModel.Input, HomeViewModel.Content> {

    struct Capabilities {
        static var mock: Capabilities {
            Capabilities(
                locationProviding: MockLocationProvider(),
                weatherProviding: MockWeatherProvider()
            )
        }

        private var locationProviding: LocationProviding
        private var weatherProviding: WeatherProviding

        init(locationProviding: LocationProviding, weatherProviding: WeatherProviding) {
            self.locationProviding = locationProviding
            self.weatherProviding = weatherProviding
        }

        func locationName(for location: CLLocation) async throws -> String {
            try await locationProviding.locationName(for: location)
        }

        func currentWeather(for location: CLLocation) async throws -> DeviceWeather {
            try await weatherProviding.currentWeather(for: location)
        }
    }

    struct Input: Equatable { }

    struct Content {
        var locationName: String
        var temperature: String
        var symbolName: String
        var realFeel: String
        var uv: String
        var windSpeed: String
    }

    static var mock: HomeViewModel {
        .init(capabilities: .mock, input: .init())
    }

    override var content: Content {
        Content(
            locationName: locationName,
            temperature: temperature,
            symbolName: symbolName,
            realFeel: realFeel,
            uv: uv,
            windSpeed: windSpeed
        )
    }

    private var errorHandler: ErrorHandler
    private var task: Task<Void, Never>?

    @Published private var locationName: String = ""
    @Published private var temperature: String = ""
    @Published private var symbolName: String = ""
    @Published private var realFeel: String = ""
    @Published private var uv: String = ""
    @Published private var windSpeed: String = ""

    init(
        capabilities: Capabilities,
        input: Input,
        errorHandler: ErrorHandler = ErrorHandler(
            plugins: [
                ToastErrorPlugin()
            ]
        )
    ) {
        self.errorHandler = errorHandler

        super.init(capabilities: capabilities, input: input)
    }

    func getWeather(for location: CLLocation) {
        task?.cancel()

        task = Task {
            if let locatioName = try? await capabilities.locationName(for: location) {
                await MainActor.run {
                    locationName = locatioName
                }
            }

            if let weather = try? await capabilities.currentWeather(for: location) {
                await MainActor.run {
                    temperature = weather.currentTemperature.abbreviatedAsProvided
                    symbolName = weather.symbolName
                    realFeel = weather.realFeel.abbreviatedAsProvided
                    uv = "\(weather.uv)"
                    windSpeed = weather.wind.speed.abbreviatedAsProvided
                }
            }
        }
    }
}
