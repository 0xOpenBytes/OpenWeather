//
//  OpenWeather template generated by OpenBytes on 23/03/2023.
//
// Created by Ahmed Shendy.
//  LocationAdapter.swift
//

import Foundation
import CoreLocation
import GRDB

enum LocationAdapter {
    static func device(from: LocationData) -> DeviceLocation {
        .init(
            name: from.name,
            latitude: from.lat,
            longitude: from.long
        )
    }

    static func device(from: Row) throws -> DeviceLocation {
        let columns: [String] = ["name", "lat", "long"]

        guard from.count == columns.count else {
            throw DatabaseError.invalidColumnCount(
                columns, columns.count,
                from.columnNames.map { "\($0)" }, from.columnNames.count
            )
        }

        for index in columns.indices {
            guard from.hasColumn(columns[index]) else {
                throw DatabaseError.missingColumn(columns[index])
            }
        }

        guard let name = from[0] as? String else {
            throw DatabaseError.invalidColumnType("name", String.self)
        }

        guard let lat = from[1] as? Double else {
            throw DatabaseError.invalidColumnType("lat", Double.self)
        }

        guard let long = from[2] as? Double else {
            throw DatabaseError.invalidColumnType("long", Double.self)
        }

        return .init(
            name: name,
            latitude: lat,
            longitude: long
        )
    }

    static func data(from: DeviceLocation) -> LocationData {
        .init(
            name: from.name,
            lat: from.latitude,
            long: from.longitude
        )
    }
}
