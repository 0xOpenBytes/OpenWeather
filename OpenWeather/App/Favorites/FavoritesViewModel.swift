//
//  OpenWeather template generated by OpenBytes on 16/03/2023.
//
// Created by Ahmed Shendy.
//  FavoritesViewModel.swift
//

import Combine
import ViewModel
import Foundation
import CoreLocation

final class FavoritesViewModel: ViewModel<
    FavoritesViewModel.Capabilities,
    FavoritesViewModel.Input,
    FavoritesViewModel.Content
> {
    struct Capabilities {
        static var mock: Capabilities {
            .init(
                locationProviding: MockLocationProvider(),
                weatherProviding: MockWeatherProvider(),
                database: MockDatabaseService()
            )
        }

        private let weatherProviding: WeatherProviding
        private let locationProviding: LocationProviding
        private let database: DatabaseService

        init(
            locationProviding: LocationProviding,
            weatherProviding: WeatherProviding,
            database: DatabaseService
        ) {
            self.locationProviding = locationProviding
            self.weatherProviding = weatherProviding
            self.database = database
        }

        func locationName(for location: CLLocation) async throws -> String {
            try await locationProviding.locationName(for: location)
        }

        func weather(for location: CLLocation) async throws -> DeviceWeather {
            try await weatherProviding.weather(for: location)
        }

        func getFavorites() async throws -> [DeviceLocation] {
            try await database.fetchAllFavorites()
        }

        func getFavoritesPublisher() -> AnyPublisher<[DeviceLocation], Error> {
            database.fetchAllFavoritesPublisher()
        }
    }

    struct Input { }

    struct Content {
        let summaries: [DeviceWeatherSummary]
    }

    override var content: Content {
        Content(summaries: summaries)
    }

    static var mock: FavoritesViewModel {
        .init(capabilities: .mock, input: .init())
    }

    private let errorHandler: ErrorHandler
    private var task: Task<Void, Never>?
    private var subscription: AnyCancellable?

    @Published private var summaries: [DeviceWeatherSummary] = []

    init(
        errorHandler: ErrorHandler = ErrorHandler(
            plugins: [ToastErrorPlugin()]
        ),
        capabilities: Capabilities,
        input: Input
    ) {
        self.errorHandler = errorHandler

        super.init(capabilities: capabilities, input: input)

        subscription = self.capabilities
            .getFavoritesPublisher()
            .flatMap { $0
                .publisher
                .setFailureType(to: Error.self)
                .asyncCompactMap(self.getWeatherSummary(for:))
                .collect()
            }
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        self.errorHandler.handle(error: error)
                    }
                },
                receiveValue: { summaries in
                    self.summaries = summaries
                }
            )
    }

    private func getWeatherSummary(
        for location: DeviceLocation
    ) async throws -> DeviceWeatherSummary? {
        guard
            let weather = try? await self.capabilities.weather(for: location.location)
        else { return nil }

        return DeviceWeatherSummary(
            locationName: location.name,
            temperature: weather.currentTemperature.abbreviatedAsProvided,
            symbolName: weather.symbolName
        )
    }

//    private func getWeatherSummary(
//        for locations: [DeviceLocation]
//    ) async throws -> [DeviceWeatherSummary] {
//        try await locations
//            .asyncCompactMap { location in
//                guard
//                    let weather = try? await self.capabilities.weather(for: location.location)
//                else { return nil }
//
//                return DeviceWeatherSummary(
//                    locationName: location.name,
//                    temperature: weather.currentTemperature.abbreviatedAsProvided,
//                    symbolName: weather.symbolName
//                )
//            }
//    }
}
