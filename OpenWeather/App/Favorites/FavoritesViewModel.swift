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
                databaseService: MockDatabaseService()
            )
        }

        private let weatherProviding: WeatherProviding
        private let locationProviding: LocationProviding
        private let databaseService: DatabaseService

        init(
            locationProviding: LocationProviding,
            weatherProviding: WeatherProviding,
            databaseService: DatabaseService
        ) {
            self.locationProviding = locationProviding
            self.weatherProviding = weatherProviding
            self.databaseService = databaseService
        }

        func locationName(for location: CLLocation) async throws -> String {
            try await locationProviding.locationName(for: location)
        }

        func weather(for location: CLLocation) async throws -> DeviceWeather {
            try await weatherProviding.weather(for: location)
        }

        func getFavoritesPublisher() -> AnyPublisher<[DeviceLocation], Error> {
            databaseService.fetchAllFavoritesPublisher()
        }

        func removeFavorite(_ location: DeviceLocation) async throws {
            try await databaseService.deleteOneFavorite(location)
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

        observeChangesInFavorites()
    }

    private func observeChangesInFavorites() {
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
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.errorHandler.handle(error: error)
                    }
                },
                receiveValue: { [weak self] summaries in
                    self?.summaries = summaries
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
            location: location,
            weather: weather
        )
    }

    // TODO: @0xLeif I choose not to hold reference to Task, multiple calls for different locations should still all be executed and none cancelled, what do you think?
    func removeFavoriteLocation(_ location: DeviceLocation) {
        Task {
            do {
                try await capabilities.removeFavorite(location)
            } catch {
                errorHandler.handle(error: error)
            }
        }
    }
}
