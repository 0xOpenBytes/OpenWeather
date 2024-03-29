//
//  OpenWeather template generated by OpenBytes on 17/03/2023.
//
// Created by Ahmed Shendy.
//  DeviceWeatherSummary.swift
//

import SwiftUI

struct DeviceWeatherSummary: Identifiable {
    let id = UUID()
    let location: DeviceLocation
    let weather: DeviceWeather

    var locationName: String { location.name }
    var temperature: String { weather.currentTemperature.abbreviatedAsProvided }
    var symbolName: String { weather.symbolName }
}

extension DeviceWeatherSummary: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.location == rhs.location
        && lhs.weather == rhs.weather
    }
}
