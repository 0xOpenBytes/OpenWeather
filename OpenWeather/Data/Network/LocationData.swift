//
//  OpenWeather template generated by OpenBytes on 22/03/2023.
//
// Created by Ahmed Shendy.
//  LocationData.swift
//

import Foundation
import CoreLocation

struct LocationData {
    let id: UUID
    let name: String
    let location: CLLocation

    init(id: UUID = UUID(), name: String, location: CLLocation) {
        self.id = id
        self.name = name
        self.location = location
    }
}

extension LocationData: CustomStringConvertible {
    var description: String {
        """
{
    id: \(id),
    name: \(name),
    latitude: \(location.coordinate.latitude),
    longitude: \(location.coordinate.longitude)
}
"""
    }
}

extension LocationData: Equatable {

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
        && lhs.location.coordinate.latitude == rhs.location.coordinate.latitude
        && lhs.location.coordinate.longitude == rhs.location.coordinate.longitude
    }
}
