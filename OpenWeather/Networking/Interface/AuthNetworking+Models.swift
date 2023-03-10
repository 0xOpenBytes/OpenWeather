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
//  AuthNetworking+Models.swift
//

import Foundation
import Test

private enum RegisterPayloadError: LocalizedError {
    case validation(reason: String)

    var errorDescription: String? {
        switch self {
        case let .validation(reason):   return "\(#fileID): Validation: \(reason)"
        }
    }
}

// swiftlint:disable identifier_name
struct RegisterPayload: Codable {
    let name: String
    let email: String
    let password: String
    let password_confirmation: String

    init(name: String, email: String, password: String, confirmationPassword: String) {
        self.name = name
        self.email = email
        self.password = password
        self.password_confirmation = confirmationPassword
    }

    func validate() throws {
        try validateEmail()
        try validateUsername()
        try validatePasswords()
    }

    private func validateEmail() throws {
        let tester = Tester()

        do {
            try Expect {
                try tester.assert(email.count < 256)

                let regex = try Regex("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,255}")

                try tester.assert(email.matches(of: regex).isEmpty == false)
            }
        } catch {
            throw RegisterPayloadError.validation(reason: "Invalid Email Address")
        }
    }

    private func validateUsername() throws {
        let tester = Tester()

        do {
            try Expect {
                try tester.assert(name.count < 256)
            }
        } catch {
            throw RegisterPayloadError.validation(reason: "Username is too long")
        }
    }

    private func validatePasswords() throws {
        let tester = Tester()

        do {
            try Expect {
                try tester.assert(password, isEqualTo: password_confirmation)

                let regex = try Regex(#"^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z]).{10, 255}$"#)

                try tester.assert(password.matches(of: regex).isEmpty == false)
            }
        } catch {
            throw RegisterPayloadError.validation(
                reason: """
                        Passwords must contain:
                            - At least 10 characters
                            - At least 1 lowercase
                            - At least 1 uppercase
                            - At least 1 number
                            - At least 1 symbol
                        """
            )
        }
    }
}

struct RegisterResponse: Codable {
    let user: NetworkUser
    let access_token: String

    var token: String { access_token }
}
// swiftlint:enable identifier_name
