//
//  See LICENSE.text for this project’s licensing information.
//
//  Paywalls.swift
//
//  Created by Bilal Durnagöl on 14.04.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// A namespace containing types and structures related to paywall requests and responses.
///
/// `Paywalls` is primarily used for fetching and decoding paywall-related information,
/// including triggers, subscriptions, and paywalls themselves.
enum Paywalls {
    
    // MARK: - Request
    
    /// A request model for fetching paywall-related data.
    ///
    /// Conforms to `Encodable` so that it can be serialized
    /// and sent in a network request. Currently, this struct is empty,
    /// but you can extend it with properties as needed.
    struct Request: Encodable { }
    
    // MARK: - Response
    
    /// A response model containing data related to triggers, subscriptions, and paywalls.
    ///
    /// Conforms to `Decodable` so that it can be constructed from JSON data.
    /// The properties map to shorter coding keys to reduce payload size.
    /// Marked as `@unchecked Sendable` to indicate it can be safely passed
    /// across concurrency boundaries, though you must ensure its internal
    /// usage is thread-safe.
    struct Response: Decodable, @unchecked Sendable {
        
        /// A collection of `Trigger` objects related to paywalls.
        ///
        /// This property is decoded from the `"ts"` key in the JSON payload.
        var triggers: [Trigger]?
        
        /// A collection of `Subscription` objects, representing various offerings.
        ///
        /// This property is decoded from the `"os"` key in the JSON payload.
        var subscriptions: [Subscription]?
        
        /// A collection of `Paywall` objects representing available paywalls.
        ///
        /// This property is decoded from the `"ps"` key in the JSON payload.
        var paywalls: [Paywall]?
        
        enum CodingKeys: String, CodingKey {
            case triggers = "ts"
            case subscriptions = "os"
            case paywalls = "ps"
        }
        
        /// Initializes a new `Response` instance by decoding from the given `Decoder`.
        ///
        /// - Parameter decoder: The decoder to read data from.
        /// - Throws: An error if any values are missing or if the data is corrupted.
        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            triggers = try container.decodeIfPresent([Trigger].self, forKey: .triggers)
            subscriptions = try container.decodeIfPresent([Subscription].self, forKey: .subscriptions)
            paywalls = try container.decodeIfPresent([Paywall].self, forKey: .paywalls)
        }
        
        // MARK: - Trigger
        
        /// A model representing a trigger for paywalls.
        ///
        /// Conforms to `Decodable` so it can be parsed from JSON.
        /// It includes an identifier, an offering ID, and a flag indicating
        /// whether this trigger is currently active.
        struct Trigger: Decodable {
            
            /// A unique identifier for this trigger.
            var triggerId: String?
            
            /// The associated offering ID.
            var offeringId: String?
            
            /// A Boolean indicating whether this trigger is currently active.
            var isCurrent: Bool?
            
            enum CodingKeys: String, CodingKey {
                case triggerId = "ti"
                case offeringId = "oi"
                case isCurrent = "ic"
            }
            
            /// Initializes a new `Trigger` instance by decoding from the given `Decoder`.
            ///
            /// - Parameter decoder: The decoder to read data from.
            /// - Throws: An error if any values are missing or if the data is corrupted.
            init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.triggerId = try container.decodeIfPresent(String.self, forKey: .triggerId)
                self.offeringId = try container.decodeIfPresent(String.self, forKey: .offeringId)
                self.isCurrent = try container.decodeIfPresent(Bool.self, forKey: .isCurrent)
            }
        }
        
        // MARK: - Subscription
        
        /// A model representing a subscription offering within the paywalls context.
        ///
        /// Conforms to `Decodable` for JSON parsing and `@unchecked Sendable` for concurrency usage.
        /// It includes an offering ID, a title, a description, an array of packages,
        /// and a flag indicating if this subscription is currently active.
        struct Subscription: Decodable, @unchecked Sendable {
            
            /// The associated offering ID.
            var offeringId: String?
            
            /// The display title of this subscription.
            var title: String?
            
            /// A description of the subscription.
            var description: String?
            
            /// A collection of `Package` objects associated with this subscription.
            var packages: [Package]?
            
            /// A Boolean indicating whether this subscription is currently active.
            var isCurrent: Bool?
            
            enum CodingKeys: String, CodingKey {
                case offeringId = "oi"
                case title = "te"
                case description = "ds"
                case packages = "pc"
                case isCurrent = "ic"
            }
            
            /// Initializes a new `Subscription` instance by decoding from the given `Decoder`.
            ///
            /// - Parameter decoder: The decoder to read data from.
            /// - Throws: An error if any values are missing or if the data is corrupted.
            init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.offeringId = try container.decodeIfPresent(String.self, forKey: .offeringId)
                self.title = try container.decodeIfPresent(String.self, forKey: .title)
                self.description = try container.decodeIfPresent(String.self, forKey: .description)
                self.packages = try container.decodeIfPresent([Package].self, forKey: .packages)
                self.isCurrent = try container.decodeIfPresent(Bool.self, forKey: .isCurrent)
            }
            
            // MARK: - Package
            
            /// A model representing a package within a subscription.
            ///
            /// Conforms to `Decodable` so it can be parsed from JSON. It includes a product identifier,
            /// a duration, and a flag indicating whether this package is currently active.
            struct Package: Decodable {
                
                /// The product identifier for this package.
                var productId: String?
                
                /// The duration (in days or another unit, as defined by the backend) of the package.
                var duration: Int?
                
                /// A Boolean indicating whether this package is currently active or selected.
                var isCurrent: Bool?
                
                enum CodingKeys: String, CodingKey {
                    case productId = "pi"
                    case duration = "dn"
                    case isCurrent = "ic"
                }
                
                /// Initializes a new `Package` instance by decoding from the given `Decoder`.
                ///
                /// - Parameter decoder: The decoder to read data from.
                /// - Throws: An error if any values are missing or if the data is corrupted.
                init(from decoder: any Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    self.productId = try container.decodeIfPresent(String.self, forKey: .productId)
                    self.duration = try container.decodeIfPresent(Int.self, forKey: .duration)
                    self.isCurrent = try container.decodeIfPresent(Bool.self, forKey: .isCurrent)
                }
            }
        }
        
        // MARK: - Paywall
        
        /// A model representing a paywall in the response.
        ///
        /// Currently an empty struct but conforms to `Decodable` for future expandability.
        struct Paywall: Decodable { }
    }
}
