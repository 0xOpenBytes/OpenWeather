//
//  OpenWeather template generated by OpenBytes on 12/21/22.
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
//  RegisterPayloadTests.swift
//

import XCTest
@testable import OpenWeather

final class RegisterPayloadTests: XCTestCase {
    enum Valid {
        static let name = "Valid Name"
        static let email = "valid.email@OB.com"
        static let password = "Validp@ss0rd"
    }

    enum Invalid {
        static let name = String(repeating: "W", count: 300)
        static let email = "invalid.emai"
        static let password = "invalid password"
    }

    func testBadUsername() throws {
        XCTAssertThrowsError(
            try RegisterPayload(
                name: Invalid.name,
                email: Valid.email,
                password: Valid.password,
                confirmationPassword: Valid.password
            )
            .validate()
        )
    }

    func testBadEmail() throws {
        XCTAssertThrowsError(
            try RegisterPayload(
                name: Valid.name,
                email: Invalid.email,
                password: Valid.password,
                confirmationPassword: Valid.password
            )
            .validate()
        )
    }

    func testBadPassword() throws {
        XCTAssertThrowsError(
            try RegisterPayload(
                name: Valid.name,
                email: Valid.email,
                password: Invalid.password,
                confirmationPassword: Invalid.password
            )
            .validate()
        )
    }

    func testMismatchedPasswords() throws {
        XCTAssertThrowsError(
            try RegisterPayload(
                name: Valid.name,
                email: Valid.email,
                password: Valid.password,
                confirmationPassword: Invalid.password
            )
            .validate()
        )
    }

    func testValidPayload() throws {
        XCTAssertNoThrow(
            try RegisterPayload(
                name: Valid.name,
                email: Valid.email,
                password: Valid.password,
                confirmationPassword: Valid.password
            )
            .validate()
        )
    }
}
