// 
//  See LICENSE.text for this project’s licensing information.
//
//  BaseError.swift
//
//  Created by Bilal Durnagöl on 24.02.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

enum BaseError: Error {
    /// Indicates a failure during the decoding process.
    ///
    /// This error is typically thrown when data cannot be decoded into the expected format.
    case decode
    
    /// Indicates that the provided URL is invalid.
    ///
    /// This error occurs when attempting to create a URL from a malformed string or when the URL does not conform to expected patterns.
    case invalidURL
    
    /// Indicates that no response was received from the server.
    ///
    /// This error is thrown when a network request completes without receiving any data, possibly due to connectivity issues or server downtime.
    case noResponse
    
    /// Indicates that the user is unauthorized.
    ///
    /// This error is typically returned when authentication fails or when the user’s session has expired.
    case unauthorized
    
    /// Indicates that an unexpected HTTP status code was received.
    ///
    /// This error is thrown when the server responds with a status code that the application does not recognize or cannot handle appropriately.
    case unexpectedStatusCode
    
    /// Represents a custom error with an optional descriptive message.
    ///
    /// - Parameter error: An optional string providing additional details about the error.
    case custom(error: String?)
    
    /// Indicates an unknown or unspecified error.
    ///
    /// This serves as a fallback for errors that do not match any of the predefined cases.
    case unknown
    
    /// Indicates that a retry operation has failed.
    ///
    /// This error is thrown when an attempt to retry a failed operation does not succeed, possibly after exhausting all retry attempts.
    case retryFailed

    /// Provides a user-friendly message describing the error.
    ///
    /// This computed property translates each `BaseError` case into a readable string that can be displayed to users or logged for debugging purposes.
    var customMessage: String {
        switch self {
        case .decode:
            return "Decode error"
        case .unauthorized:
            return "Session expired"
        case .custom(let error):
            return error ?? "Unknown error"
        default:
            return "Unknown error"
        }
    }
}
