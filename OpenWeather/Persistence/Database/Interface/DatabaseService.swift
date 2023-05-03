//
//  OpenWeather template generated by OpenBytes on 30/04/2023.
//
// Created by Ahmed Shendy.
//  DatabaseService.swift
//

import Foundation

protocol DatabaseService {
    static func empty() throws -> Self

    func tableExists(_ name: String) async throws -> Bool
    func columns(in name: String) async throws -> [String]

    // Favorites Table
    func favoriteExists(_ location: LocationData) async throws -> Bool
    func findFavoriteLocation(_ location: LocationData) async throws -> LocationData?
    func insertFavoriteLocation(_ location: LocationData) async throws
    func deleteFavoriteLocation(_ location: LocationData) async throws
}
