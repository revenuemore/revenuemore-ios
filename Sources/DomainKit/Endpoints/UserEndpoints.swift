// 
//  See LICENSE.text for this project’s licensing information.
//
//  UsersEndpoint.swift
//
//  Created by Bilal Durnagöl on 17.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// An enumeration representing various endpoints related to user operations.
///
/// Use `UserEndpoints` to specify the specific API calls for user-related operations,
/// such as updating a user’s information.
enum UserEndpoints {
    
    /// A case representing the endpoint to update a user’s information.
    ///
    /// - Parameter request: A `UserUpdate.Request` struct containing the data necessary
    ///   to update the user's information.
    case userUpdate(UserUpdate.Request)
}

/// An extension that conforms `UserEndpoints` to the `Endpoint` protocol,
/// defining the `path`, `method`, and `body` properties used in network requests.
extension UserEndpoints: Endpoint {
    
    /// The URL path for user endpoints.
    ///
    /// All requests for user-related operations will be appended to this path.
    var path: String {
        return "users"
    }

    /// The HTTP method used for user requests.
    ///
    /// All user update requests are handled via the `PUT` method.
    var method: HTTPMethod {
        return .put
    }

    /// The request body or parameters for each user request.
    ///
    /// For a user update request, the parameters are encoded in the HTTP body
    /// (i.e., `.requestParameters(parameters:encoding:.httpBody)`).
    var body: HTTPTask {
        switch self {
        case .userUpdate(let request):
            return .requestParameters(parameters: request.dictionary, encoding: .httpBody)
        }
    }
}
