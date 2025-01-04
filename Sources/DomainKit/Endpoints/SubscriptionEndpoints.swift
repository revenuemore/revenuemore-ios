// 
//  See LICENSE.text for this project’s licensing information.
//
//  SubscriptionsEndpoint.swift
//
//  Created by Bilal Durnagöl on 7.07.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// An enumeration representing various endpoints related to subscriptions.
///
/// Use `SubscriptionEndpoints` to specify the specific API calls for subscription-related operations:
/// - Completing a payment (`.complete`)
/// - Retrieving subscriptions (`.subscriptions`)
enum SubscriptionEndpoints {
    
    /// A case representing the endpoint to complete a payment.
    ///
    /// - Parameter request: A `PaymentComplete.Request` struct containing the parameters required
    ///   to complete a payment.
    case complete(PaymentComplete.Request)
    
    /// A case representing the endpoint to retrieve a user's subscriptions.
    ///
    /// - Parameter request: A `UserSubscription.Request` struct containing the parameters required
    ///   to fetch subscription details.
    case subscriptions(UserSubscription.Request)
}

/// An extension that conforms `SubscriptionEndpoints` to the `Endpoint` protocol,
/// defining the `path`, `method`, and `body` properties used in network requests.
extension SubscriptionEndpoints: Endpoint {
    
    /// The URL path for subscription endpoints.
    ///
    /// All requests for subscriptions will be appended to this path.
    var path: String {
        return "subscriptions"
    }

    /// The HTTP method to use for each subscription request.
    ///
    /// - `.complete`: Uses `POST`
    /// - `.subscriptions`: Uses `GET`
    var method: HTTPMethod {
        switch self {
        case .complete:
            return .post
        case .subscriptions:
            return .get
        }
    }

    /// The request body or query parameters for each subscription request.
    ///
    /// - `.complete`: Encodes the payment completion parameters as `.httpBody`.
    /// - `.subscriptions`: Encodes the subscription query parameters as `.query`.
    ///
    /// This uses a `request.dictionary` to serialize the request data from the associated values.
    var body: HTTPTask {
        switch self {
        case .complete(let request):
            return .requestParameters(parameters: request.dictionary, encoding: .httpBody)
        case .subscriptions(let request):
            return .requestParameters(parameters: request.dictionary, encoding: .query)
        }
    }
}
