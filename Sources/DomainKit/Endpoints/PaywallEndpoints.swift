// 
//  See LICENSE.text for this project’s licensing information.
//
//  PaywallsEndpoint.swift
//
//  Created by Bilal Durnagöl on 14.04.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// An enumeration representing various endpoints related to paywalls.
///
/// Use `PaywallEndpoints` to specify the specific API calls for paywall-related operations, such as fetching
/// available paywalls. Each case corresponds to a particular endpoint within your service’s paywall API.
enum PaywallEndpoints {
    
    /// A case representing the endpoint to fetch the available paywalls.
    case fetchPaywalls
}

/// An extension that conforms `PaywallEndpoints` to the `Endpoint` protocol,
/// defining the `path`, `method`, and `body` properties required by the protocol.
extension PaywallEndpoints: Endpoint {
    
    /// The URL path for the paywall endpoints.
    ///
    /// All requests for paywalls will be appended to this path.
    var path: String {
        return "paywalls"
    }

    /// The HTTP method to use for the request.
    ///
    /// Currently, all paywall requests use the `GET` method.
    var method: HTTPMethod {
        return .get
    }

    /// The request body payload for the paywall request.
    ///
    /// For `.fetchPaywalls`, it uses `.requestPlain`, indicating a request with no additional parameters or body.
    var body: HTTPTask {
        switch self {
        case .fetchPaywalls:
            return .requestPlain
        }
    }
}
