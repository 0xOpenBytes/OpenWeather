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

    func locations(for address: String) async throws -> [DeviceLocation] {
        let response: LocationSearchResponse = try await locations(for: address)

        return response.result.map(LocationAdapter.device(from:))
    }

    private func locations(for address: String) async throws -> LocationSearchResponse {
        return try await withCheckedThrowingContinuation { continuation in
            locations(
                for: address,
                completion: { placemarks, error in
                    if let error = error {
                        continuation.resume(
                            throwing: LocationProvidingError.failure(reason: error.localizedDescription)
                        )
                    } else {
                        let result: [NetworkLocation] = placemarks
                            .compactMap { placemark -> NetworkLocation? in
                                guard
                                    let name = placemark.name,
                                    let location = placemark.location
                                else { return nil }

                                return NetworkLocation(
                                    name: name,
                                    location: location
                                )
                            }

                        continuation.resume(
                            returning: LocationSearchResponse(result: result)
                        )
                    }
                }
            )
        }
    }

    private func locations(
        for address: String,
        completion: @escaping ([CLPlacemark], Error?) -> Void
    ) {
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error as? NSError {
                completion([], error)
            } else {
                completion(placemarks ?? [], nil)
            }
        }
    }
}

struct MockLocationProvider: LocationProviding {
    func locationName(for location: CLLocation) async throws -> String {
        return Mock.locationNameMap[location] ?? "Unknown"
    }

    func locations(for address: String) async throws -> [DeviceLocation] {
        guard address.isEmpty == false else { return [] }

        return Mock.locationsMap
            .compactMap { (key, value) -> DeviceLocation? in 
                return key.lowercased().contains(address.lowercased()) ? value : nil
            }
    }
}
