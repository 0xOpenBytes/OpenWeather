//
//  OpenWeather template generated by OpenBytes on 12/14/22.
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
//  HomeScreen.swift
//

import SwiftUI
import CoreLocation

struct HomeScreen: View {
    private let location: CLLocation = .init(latitude: 51.5072, longitude: 0.1276)

    @ObservedObject var settings: AppSettings = AppSettings.shared
    @ObservedObject var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            VStack(spacing: 15) {
                Image(systemName: viewModel.symbolName)
                    .symbolRenderingMode(.monochrome)
                    .foregroundColor(.gray)
                    .font(.system(size: 100))
                    .padding(.bottom, 20)

                Text("Current Weather: \(viewModel.locationName)")
                    .font(.title3)
                    .fontWeight(.bold)

                HStack {
                    Text("\(viewModel.temperature)")
                        .font(.system(size: 75))
                        .fontWeight(.heavy)
                        .foregroundColor(.blue)
                }

                HStack {
                    VStack {
                        Text("\(viewModel.windSpeed)")
                            .fontWeight(.bold)
                            .foregroundColor(.black)

                        Text("Wind")
                            .foregroundColor(.black)
                    }
                    .font(.system(size: 25))

                    Spacer()

                    VStack {
                        Text("\(viewModel.uv)")
                            .fontWeight(.bold)
                            .foregroundColor(.black)

                        Text("UV")
                            .foregroundColor(.black)
                    }
                    .font(.system(size: 25))

                    Spacer()

                    VStack {
                        Text("\(viewModel.realFeel)")
                            .fontWeight(.bold)
                            .foregroundColor(.black)

                        Text("Feel")
                            .foregroundColor(.black)
                    }
                    .font(.system(size: 25))
                }
                .padding(.horizontal, 50)
            }
        }
        .navigationTitle("Hello, \(settings.user?.username ?? "World")!")
        .toolbar {
            Button(
                action: {
                    Navigation.path.modal {
                        NavigationStack {
                            AcknowledgmentView()
                        }
                    }
                },
                label: {
                    Image(systemName: "info.circle")
                }
            )
        }
        .onAppear {
            viewModel.getWeather(for: location)
        }
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen(
            viewModel: HomeViewModel(
                weatherProviding: MockWeatherProvider(),
                locationProviding: MockLocationProvider()
            )
        )
    }
}
