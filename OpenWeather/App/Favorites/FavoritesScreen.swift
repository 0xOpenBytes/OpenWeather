//
//  OpenWeather template generated by OpenBytes on 16/03/2023.
//
// Created by Ahmed Shendy.
//  FavoritesScreen.swift
//

import SwiftUI
import CoreLocation

struct FavoritesScreen: View {
    @StateObject var viewModel: FavoritesViewModel

    var body: some View {
        viewModel.view { content in
            if content.summaries.isEmpty {
                Text("No Favorites Available")
            } else {
                List {
                    ForEach(content.summaries) { favorite in
                        LocationWeatherItem(
                            locationName: favorite.locationName,
                            temperature: favorite.temperature,
                            symbolName: favorite.symbolName
                        )
                        .swipeActions(allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                print("ToBeRemoved")
                            } label: {
                                Label("Remove", systemImage: "heart.slash")
                            }
                            .tint(.red)
                        }
                    }
                }
            }
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
        FavoritesScreen(viewModel: .mock)
    }
}