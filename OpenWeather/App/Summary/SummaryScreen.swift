//
//  OpenWeather template generated by OpenBytes on 16/03/2023.
//
// Created by Ahmed Shendy.
//  SummaryScreen.swift
//

import SwiftUI
import CoreLocation

struct SummaryScreen: View {
    private let locations: [CLLocation] = [.london, .cairo, .newYork]

    @ObservedObject var viewModel: SummaryViewModel

    var body: some View {
        List {
            ForEach(viewModel.summaries) { summary in
                LocationWeatherItem(
                    locationName: summary.locationName,
                    temperature: summary.temperature,
                    symbolName: summary.symbolName
                )
            }
        }
        .onAppear {
            viewModel.getWeatherSummary(for: locations)
        }
    }
}

struct LocationWeatherItem: View {
    let locationName: String
    let temperature: String
    let symbolName: String

    var body: some View {
        HStack {
            Text(locationName)
            Spacer()
            Text(temperature)
            Image(systemName: symbolName)
        }
    }
}

struct SummaryScreen_Previews: PreviewProvider {
    static var previews: some View {
        SummaryScreen(
            viewModel: SummaryViewModel(
                weatherProviding: MockWeatherProvider(),
                locationProviding: MockLocationProvider()
            )
        )
    }
}