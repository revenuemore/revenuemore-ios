//
//  See LICENSE.text for this project's licensing information.
//
//  Environment.swift
//
//  Created by RevenueMore on 17.01.2026.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// Represents the backend environment configuration for the RevenueMore SDK.
///
/// Use this enum to specify which backend environment the SDK should connect to.
/// This is useful for development, testing, and production scenarios.
///
/// **Example Usage**:
/// ```swift
/// RevenueMore.start(
///     apiKey: "your-api-key",
///     userId: "user_123",
///     environment: .stage  // Use stage environment for testing
/// )
/// ```
public enum RMEnvironment: String, Sendable {

    /// Production environment - `api.revenuemore.com`
    ///
    /// Use this for live, production apps.
    case production

    /// Staging environment - `backend-stage.revenuemore.com`
    ///
    /// Use this for testing with staging backend.
    case stage

    /// Development environment - `backend-dev.revenuemore.com`
    ///
    /// Use this for development and debugging.
    case development

    /// The base URL host for the selected environment.
    var host: String {
        switch self {
        case .production:
            return "api.revenuemore.com"
        case .stage:
            return "backend-stage.revenuemore.com"
        case .development:
            return "backend-dev.revenuemore.com"
        }
    }

    /// The full base path including the API prefix.
    var basePath: String {
        return "/api"
    }
}

/// Global environment configuration used by the SDK.
///
/// This is set during SDK initialization and used by all network requests.
internal final class EnvironmentConfiguration: @unchecked Sendable {

    /// Shared singleton instance.
    static let shared = EnvironmentConfiguration()

    /// The current environment. Defaults to production.
    private(set) var current: RMEnvironment = .production

    private init() {}

    /// Sets the current environment.
    /// - Parameter environment: The environment to use.
    func setEnvironment(_ environment: RMEnvironment) {
        self.current = environment
    }
}
