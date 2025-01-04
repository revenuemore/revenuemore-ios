// 
//  See LICENSE.text for this project’s licensing information.
//
//  Endpoint.swift
//
//  Created by Bilal Durnagöl on 24.02.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

typealias HTTPHeaders = [String: String]

protocol Endpoint {

    /// A string representation of the scheme for the request.
    var scheme: String { get }

    /// A string representation of the host for the request.
    var host: String { get }

    /// A string representation of the path for the request.
    var path: String { get }

    var apiVersion: String { get }

    /// The HTTP method for the request.
    var method: HTTPMethod { get }

    /// The HTTP header fields for the request.
    var headers: HTTPHeaders? { get }

    /// The HTTP body for the request.
    var body: HTTPTask { get }
}

extension Endpoint {

    var scheme: String {
        return "https://"
    }

    var host: String {
        return "api.revenuemore.com/api"
    }

    var apiVersion: String {
        return "/v1/"
    }

    var headers: HTTPHeaders? { return nil }
}
