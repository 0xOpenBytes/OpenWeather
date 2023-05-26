//
//  OpenWeather template generated by OpenBytes on 22/03/2023.
//
// Created by Ahmed Shendy.
//  SearchLocationViewModel.swift
//

import Combine
import ViewModel
import Foundation
import CoreLocation

final class SearchLocationViewModel: ViewModel<
    SearchLocationViewModel.Capabilities,
    SearchLocationViewModel.Input,
    SearchLocationViewModel.Content
> {
    struct Capabilities {
        static var mock: Capabilities {
            .init(
                locationProviding: MockLocationProvider(),
                databaseService: MockDatabaseService()
            )
        }

        private var locationProviding: LocationProviding
        private var databaseService: DatabaseService

        init(
            locationProviding: LocationProviding,
            databaseService: DatabaseService
        ) {
            self.locationProviding = locationProviding
            self.databaseService = databaseService
        }

        func getLocations(query: String) async throws -> [DeviceLocation] {
            var locations = try await locationProviding.locations(for: query)
            let favorites = try await databaseService.fetchAllFavorites(matching: locations)

            for index in locations.indices {
                locations[index].isFavorite = favorites.contains(locations[index])
            }

            return locations
        }

        func toggleFavorite(for location: DeviceLocation) async throws -> DeviceLocation {
            var updated = location
            if try await databaseService.favoriteExists(updated) {
                try await databaseService.deleteOneFavorite(updated)
                updated.isFavorite = false

            } else {
                try await databaseService.insertOneFavorite(updated)
                updated.isFavorite = true
            }

            return updated
        }
    }

    struct Input: Equatable {
        var searchText: String = ""
    }

    struct Content {
        var result: [DeviceLocation]
    }

    static var mock: SearchLocationViewModel {
        .init(capabilities: .mock, input: .init())
    }

    override var input: Input {
        didSet {
            guard input != oldValue else { return }

            searchSubject.send(input.searchText)
        }
    }

    override var content: Content {
        Content(result: result)
    }

    private var errorHandler: ErrorHandler
    private let searchSubject: CurrentValueSubject<String, Never> = CurrentValueSubject("")

    private var searchTask: Task<Void, Never>?
    private var toggleFavoriteTask: Task<Void, Never>?
    private var searchSubscription: AnyCancellable?

    @Published private var result: [DeviceLocation] = []

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

        observeSearchKeywords()
    }

    private func observeSearchKeywords() {
        searchSubscription = searchSubject
            .removeDuplicates()
            .debounce(for: 0.300, scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                self?.getLocations(searchText: searchText)
            }
    }

    private func getLocations(searchText: String) {
        searchTask?.cancel()

        guard searchText.isEmpty == false else {
            self.result = []
            return
        }

        searchTask = Task {
            do {
                guard searchTask?.isCancelled == false else { return }

                let result = try await capabilities.getLocations(query: searchText)

                guard searchTask?.isCancelled == false else { return }

                await MainActor.run {
                    self.result = result
                }
            } catch {
                errorHandler.handle(error: error)
            }
        }
    }

    func toggleFavorite(for location: DeviceLocation) {
        toggleFavoriteTask?.cancel()

        toggleFavoriteTask = Task {
            do {
                let updated = try await capabilities.toggleFavorite(for: location)

                if let index = self.result.firstIndex(of: updated) {
                    await MainActor.run {
                        self.result[index] = updated
                    }
                }
            } catch {
                errorHandler.handle(error: error)
            }
        }
    }
}
