// 
//  See LICENSE.text for this project’s licensing information.
//
//  UserSubscriptions.swift
//
//  Created by Bilal Durnagöl on 13.07.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// A namespace for types related to user subscription requests and responses.
///
/// Use `UserSubscription` when you need to request subscription data from a backend
/// or when you need to parse subscription response objects.
enum UserSubscription {
    
    // MARK: - Request
    
    /// A request model for fetching user subscriptions.
    ///
    /// Conforms to `Encodable` so it can be serialized into JSON.
    /// It includes a subscription type (`type`) that can be all, active, or expired.
    struct Request: Encodable {
        
        /// The type of subscription to be requested (e.g., `.all`, `.active`, `.expired`).
        var type: SubscriptionType

        enum CodingKeys: String, CodingKey {
            case type = "ty"
        }

        /// An enumeration describing the types of subscriptions to fetch.
        ///
        /// Each case is mapped to a string for serialization:
        /// - `.all` → `"al"`
        /// - `.active` → `"ac"`
        /// - `.expired` → `"ex"`
        enum SubscriptionType: String, Encodable {
            /// Fetch all subscriptions.
            case all = "al"
            /// Fetch only currently active subscriptions.
            case active = "ac"
            /// Fetch subscriptions that have expired.
            case expired = "ex"
        }
    }

    // MARK: - Response
    
    /// A response model containing a list of user subscriptions.
    ///
    /// Conforms to `Decodable` so it can be constructed from JSON data.
    /// The `subscriptions` property maps to an array of `Subscription` objects
    /// decoded from the `"sbs"` key in the JSON.
    struct Response: Decodable {
        
        /// An array of `Subscription` objects describing the user’s subscriptions.
        ///
        /// Decoded from the `"sbs"` key in the JSON payload.
        var subscriptions: [Subscription]?

        enum CodingKeys: String, CodingKey {
            case subscriptions = "sbs"
        }

        /// A model representing a single user subscription record.
        ///
        /// Conforms to `Decodable` to parse JSON data. It includes
        /// various fields (e.g., `price`, `currency`, `productId`, etc.)
        /// to describe the subscription’s purchase and renewal status.
        struct Subscription: Decodable {
            
            /// The renew status of the subscription.
            ///
            /// This might be used to indicate whether auto-renew is enabled,
            /// disabled, or in a different state (implementation-specific).
            var renewStatus: Int?
            
            /// The price of the subscription, in the currency specified by `currency`.
            var price: Double?
            
            /// A string representing the subscription's currency code (e.g., `"USD"`).
            var currency: String?
            
            /// The purchase date of the subscription, represented as a time interval since 1970.
            var purchaseDate: Double?
            
            /// The quantity of subscriptions purchased in this transaction.
            var quantity: Int?
            
            /// The start date of the subscription, as a time interval since 1970.
            var startDate: Double?
            
            /// The next renewal date for the subscription, as a time interval since 1970.
            var renewalDate: Double?
            
            /// A status indicating which service or tier the user has.
            var serviceStatus: Int?
            
            /// The expiration date of the subscription, as a time interval since 1970.
            var expiresDate: Double?
            
            /// The product identifier (e.g., `"com.company.app.subscription"`).
            var productId: String?

            enum CodingKeys: String, CodingKey {
                case renewStatus = "ars"
                case price = "pe"
                case currency = "cy"
                case purchaseDate = "pd"
                case quantity = "qy"
                case startDate = "rssd"
                case renewalDate = "rd"
                case serviceStatus = "ss"
                case expiresDate = "ed"
                case productId = "pid"
            }
        }
    }
}
