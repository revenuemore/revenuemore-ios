//
//  See LICENSE.text for this project's licensing information.
//
//  SubscriptionGroupEndpoints.swift
//
//  Created by Bilal Durnagöl on 14.04.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// An enumeration representing various endpoints related to subscription groups.
///
/// Use `SubscriptionGroupEndpoints` to specify the specific API calls for subscription group-related operations,
/// such as fetching available subscription groups. Each case corresponds to a particular endpoint within your
/// service's store API.
enum SubscriptionGroupEndpoints {

    /// A case representing the endpoint to fetch the available subscription groups.
    case fetchSubscriptionGroups
}

/// An extension that conforms `SubscriptionGroupEndpoints` to the `Endpoint` protocol,
/// defining the `path`, `method`, and `body` properties required by the protocol.
extension SubscriptionGroupEndpoints: Endpoint {

    /// The URL path for the subscription group endpoints.
    ///
    /// All requests for subscription groups will be appended to this path.
    var path: String {
        return "store/subscription-groups"
    }

    /// The HTTP method to use for the request.
    ///
    /// Currently, all subscription group requests use the `GET` method.
    var method: HTTPMethod {
        return .get
    }

    /// The request body payload for the subscription group request.
    ///
    /// For `.fetchSubscriptionGroups`, it uses `.requestPlain`, indicating a request with no additional parameters or body.
    var body: HTTPTask {
        switch self {
        case .fetchSubscriptionGroups:
            return .requestPlain
        }
    }
}
