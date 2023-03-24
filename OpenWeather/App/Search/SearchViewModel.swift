//
//  OpenWeather template generated by OpenBytes on 22/03/2023.
//
// Created by Ahmed Shendy.
//  SearchViewModel.swift
//

import Foundation
import CoreLocation

final class SearchViewModel: ObservableObject, ErrorHandling {
    private var locationProviding: LocationProviding
    private var task: Task<Void, Never>?

    var errorHandler: ErrorHandler

    @Published var searchText: String = ""
    @Published var result: [DeviceLocation] = []

    init(
        locationProviding: LocationProviding,
        errorHandler: ErrorHandler = ErrorHandler(
            plugins: [
                ToastErrorPlugin()
            ]
        )
    ) {
        self.locationProviding = locationProviding
        self.errorHandler = errorHandler
    }

    func getLocations() {
        task?.cancel()

        task = Task {
            do {
                guard let result = try await getLocations() else { return }

                await MainActor.run {
                    self.result = result
                }
            } catch {
                errorHandler.handle(error: error)
            }
        }
    }

    func getLocations() async throws -> [DeviceLocation]? {
        try? await Task.withCheckedCancellation {
            try await locationProviding.locations(for: searchText)
        }
    }
}
