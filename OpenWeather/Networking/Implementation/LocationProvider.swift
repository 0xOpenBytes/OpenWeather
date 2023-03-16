//
//  OpenWeather template generated by OpenBytes on 15/03/2023.
//
// Created by Ahmed Shendy.
//  LocationProvider.swift
//

import Foundation
import CoreLocation

struct LocationProvider: LocationProviding {

    private let geocoder: CLGeocoder = .init()

    func locationName(for location: CLLocation) async throws -> String {
        let response: LocationNameResponse = try await locationName(for: location)

        return response.name
    }

    private func locationName(for location: CLLocation) async throws -> LocationNameResponse {
        return try await withCheckedThrowingContinuation { continuation in
            locationName(
                for: location,
                completion: { placemark, error in
                    if let error = error {
                        continuation.resume(
                            throwing: LocationProvidingError.failure(reason: error.localizedDescription)
                        )
                    } else {
                        if let locationName = placemark?.name {
                            continuation.resume(
                                returning: LocationNameResponse(name: locationName)
                            )
                        } else {
                            continuation.resume(
                                throwing: LocationProvidingError.noSuchPlace
                            )
                        }
                    }
                }
            )
        }
    }

    private func locationName(
        for location: CLLocation,
        completion: @escaping (CLPlacemark?, Error?) -> Void
    ) {
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error as? NSError {
                completion(nil, error)
            } else {
                completion(placemarks?.first, nil)
            }
        }
    }
}

struct MockLocationProvider: LocationProviding {
    func locationName(for location: CLLocation) async throws -> String {
        return "London`"
    }
}