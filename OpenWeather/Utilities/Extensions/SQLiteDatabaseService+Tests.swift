//
//  OpenWeather template generated by OpenBytes on 01/06/2023.
//
// Created by Ahmed Shendy.
//  SQLiteDatabaseService+Tests.swift
//

import Foundation
import GRDB

extension SQLiteDatabaseService {
    static func empty() throws -> SQLiteDatabaseService {
        let dbQueue = try DatabaseQueue(
            configuration: SQLiteDatabaseService.makeConfiguration()
        )

        return try SQLiteDatabaseService(dbQueue)
    }
}