// 
//  See LICENSE.text for this project’s licensing information.
//
//  UserUpdate.swift
//
//  Created by Bilal Durnagöl on 17.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// A namespace for types related to updating user information.
///
/// `UserUpdate` contains a `Request` for sending user update details
/// and a `Response` for handling the server’s response to that update.
enum UserUpdate {
    
    /// A request model for updating a user’s information.
    ///
    /// Conforms to `Encodable` so it can be serialized into JSON.
    /// - Important: This request expects a `userId` parameter that
    ///   may be `nil` if not available.
    struct Request: Encodable {
        
        /// An optional identifier for the user.
        ///
        /// Encoded using the key `"mr"` when serialized to JSON.
        let userId: String?
        
        enum CodingKeys: String, CodingKey {
            case userId = "mr"
        }
    }
    
    /// A response model returned after a user update request.
    ///
    /// Conforms to `Decodable`, but currently has no properties defined.
    /// Extend this struct with properties as needed when the server’s
    /// response format changes or becomes more detailed.
    struct Response: Decodable { }
}
