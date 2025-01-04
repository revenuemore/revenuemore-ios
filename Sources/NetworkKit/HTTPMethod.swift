// 
//  See LICENSE.text for this project’s licensing information.
//
//  HTTPMethod.swift
//
//  Created by Bilal Durnagöl on 24.02.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

/// Type representing HTTP methods. Raw `String` value is stored and compared case-sensitively, so
/// `HTTPMethod.get != HTTPMethod(rawValue: "get")`.
///
/// See https://tools.ietf.org/html/rfc7231#section-4.3
struct HTTPMethod: RawRepresentable, Equatable, Hashable {
    /// `CONNECT` method.
    static let connect = HTTPMethod(rawValue: "CONNECT")
    /// `DELETE` method.
    static let delete = HTTPMethod(rawValue: "DELETE")
    /// `GET` method.
    static let get = HTTPMethod(rawValue: "GET")
    /// `HEAD` method.
    static let head = HTTPMethod(rawValue: "HEAD")
    /// `OPTIONS` method.
    static let options = HTTPMethod(rawValue: "OPTIONS")
    /// `PATCH` method.
    static let patch = HTTPMethod(rawValue: "PATCH")
    /// `POST` method.
    static let post = HTTPMethod(rawValue: "POST")
    /// `PUT` method.
    static let put = HTTPMethod(rawValue: "PUT")
    /// `QUERY` method.
    static let query = HTTPMethod(rawValue: "QUERY")
    /// `TRACE` method.
    static let trace = HTTPMethod(rawValue: "TRACE")

    let rawValue: String
}
