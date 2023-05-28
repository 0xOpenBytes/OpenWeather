//
//  OpenWeather template generated by OpenBytes on 12/22/22.
//  Copyright (c) 2023 OpenBytes
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the conditions found at the following link:
//  https://github.com/0xOpenBytes/ios-BASE/blob/main/LICENSE
//
// Created by Leif.
//  MockData.swift
//

import Foundation
import CoreLocation

extension Mock {
    static let users: [User] = [
        User(username: "Red User", email: "1@mock.dev", color: .red),
        User(username: "Green User", email: "2@mock.dev", color: .green),
        User(username: "Blue User", email: "3@mock.dev", color: .blue)
    ]

    static let londonLocation: CLLocation = .london
    static let londonWeather: DeviceWeather = .london

    static let locationWeatherMap: [LocationData : DeviceWeather] = [
        .london : .london,
        .cairo : .cairo,
        .newYork: .newYork
    ]

    static let locationNameMap: [CLLocation : String] = [
        .london : LocationData.london.name,
        .cairo : LocationData.cairo.name,
        .newYork : LocationData.newYork.name
    ]

    static let locationsMap: [String : DeviceLocation] = [
        "London": .london,
        "4240120": DeviceLocation(name: "Manial Al-Rodha", location: .cairo),
        "New York": .newYork,
        "New Zealand": .newZealand
    ]
}

extension CLLocation {
    static let london: CLLocation = .init(latitude: 51.5072, longitude: 0.1276)
    static let cairo: CLLocation = .init(latitude: 30.0444, longitude: 31.2357)
    static let newYork: CLLocation = .init(latitude: 40.7128, longitude: 74.0060)
    static let newZealand: CLLocation = .init(latitude: 40.9006, longitude: 174.8860)
}

extension LocationData {
    static let london: LocationData = .init(
        name: "London",
        location: .london
    )

    static let cairo: LocationData = .init(
        name: "Cairo",
        location: .cairo
    )

    static let newYork: LocationData = .init(
        name: "New York",
        location: .newYork
    )

    static let newZealand: LocationData = .init(
        name: "New Zealand",
        location: .newZealand
    )
}

extension DeviceLocation {
    static let london: DeviceLocation = LocationAdapter.device(from: .london)
    static let cairo: DeviceLocation = LocationAdapter.device(from: .cairo)
    static let newYork: DeviceLocation = LocationAdapter.device(from: .newYork)
    static let newZealand: DeviceLocation = LocationAdapter.device(from: .newZealand)
}

extension DeviceWeatherSummary {
    static let london: DeviceWeatherSummary = .init(
        location: .london,
        weather: .london
    )
    static let cairo: DeviceWeatherSummary = .init(
        location: .cairo,
        weather: .cairo
    )
    static let newYork: DeviceWeatherSummary = .init(
        location: .newYork,
        weather: .newYork
    )
}

extension DeviceWeather {
    static let london: DeviceWeather = .init(
        currentTemperature: .init(value: 11, unit: .celsius),
        realFeel: .init(value: 10.2, unit: .celsius),
        uv: 1,
        symbolName: "cloud.drizzle.fill",
        wind: DeviceWind(
            direction: .init(value: 0, unit: .degrees),
            speed: .init(value: 10, unit: .kilometersPerHour),
            gust: nil),
        hourlyForecast: [
            DeviceHourlyForecast(
                date: .now,
                temperature: .init(value: 0, unit: .celsius),
                symbolName: "cloud"
            )
        ]
    )

    static let cairo: DeviceWeather = .init(
        currentTemperature: .init(value: 18, unit: .celsius),
        realFeel: .init(value: 10.2, unit: .celsius),
        uv: 1,
        symbolName: "sun.min",
        wind: DeviceWind(
            direction: .init(value: 0, unit: .degrees),
            speed: .init(value: 10, unit: .kilometersPerHour),
            gust: nil),
        hourlyForecast: [
            DeviceHourlyForecast(
                date: .now,
                temperature: .init(value: 0, unit: .celsius),
                symbolName: "cloud"
            )
        ]
    )

    static let newYork: DeviceWeather = .init(
        currentTemperature: .init(value: 9, unit: .celsius),
        realFeel: .init(value: 10.2, unit: .celsius),
        uv: 1,
        symbolName: "smoke.fill",
        wind: DeviceWind(
            direction: .init(value: 0, unit: .degrees),
            speed: .init(value: 10, unit: .kilometersPerHour),
            gust: nil),
        hourlyForecast: [
            DeviceHourlyForecast(
                date: .now,
                temperature: .init(value: 0, unit: .celsius),
                symbolName: "cloud"
            )
        ]
    )
}
