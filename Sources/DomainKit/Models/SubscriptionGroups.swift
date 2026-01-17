//
//  See LICENSE.text for this project's licensing information.
//
//  SubscriptionGroups.swift
//
//  Created by Bilal Durnagöl on 14.04.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// A namespace containing types and structures related to subscription group requests and responses.
///
/// `SubscriptionGroups` is primarily used for fetching and decoding subscription group information
/// from the store API.
enum SubscriptionGroups {

    // MARK: - Request

    /// A request model for fetching subscription group data.
    ///
    /// Conforms to `Encodable` so that it can be serialized
    /// and sent in a network request. Currently, this struct is empty,
    /// but you can extend it with properties as needed.
    struct Request: Encodable { }

    // MARK: - Response

    /// A response model containing subscription groups from the store API.
    ///
    /// Conforms to `Decodable` so that it can be constructed from JSON data.
    /// The properties map to shorter coding keys to reduce payload size.
    /// Marked as `@unchecked Sendable` to indicate it can be safely passed
    /// across concurrency boundaries, though you must ensure its internal
    /// usage is thread-safe.
    struct Response: Decodable, @unchecked Sendable {

        // MARK: - Triggers (Disabled)
        // Triggers will be re-enabled when the feature is implemented on backend
        // /// A collection of `Trigger` objects related to subscription groups.
        // var triggers: [Trigger]?

        /// A collection of `SubscriptionGroup` objects from the store API.
        ///
        /// This property is decoded from the `"data"` key in the JSON payload.
        var subscriptionGroups: [SubscriptionGroup]?

        // MARK: - Paywalls (Removed)
        // Paywalls are no longer returned from this endpoint

        enum CodingKeys: String, CodingKey {
            // case triggers = "ts"  // Disabled
            case subscriptionGroups = "data"
        }

        /// Initializes a new `Response` instance by decoding from the given `Decoder`.
        ///
        /// - Parameter decoder: The decoder to read data from.
        /// - Throws: An error if any values are missing or if the data is corrupted.
        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            // triggers = try container.decodeIfPresent([Trigger].self, forKey: .triggers)  // Disabled
            subscriptionGroups = try container.decodeIfPresent([SubscriptionGroup].self, forKey: .subscriptionGroups)
        }

        // MARK: - Trigger (Disabled for now)
        /*
        /// A model representing a trigger for subscription groups.
        ///
        /// Conforms to `Decodable` so it can be parsed from JSON.
        /// It includes an identifier, a subscription group ID, and a flag indicating
        /// whether this trigger is currently active.
        struct Trigger: Decodable {

            /// A unique identifier for this trigger.
            var triggerId: String?

            /// The associated subscription group ID.
            var subscriptionGroupId: String?

            /// A Boolean indicating whether this trigger is currently active.
            var isCurrent: Bool?

            enum CodingKeys: String, CodingKey {
                case triggerId = "ti"
                case subscriptionGroupId = "sgi"
                case isCurrent = "ic"
            }

            /// Initializes a new `Trigger` instance by decoding from the given `Decoder`.
            ///
            /// - Parameter decoder: The decoder to read data from.
            /// - Throws: An error if any values are missing or if the data is corrupted.
            init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.triggerId = try container.decodeIfPresent(String.self, forKey: .triggerId)
                self.subscriptionGroupId = try container.decodeIfPresent(String.self, forKey: .subscriptionGroupId)
                self.isCurrent = try container.decodeIfPresent(Bool.self, forKey: .isCurrent)
            }
        }
        */

        // MARK: - SubscriptionGroup

        /// A model representing a subscription group from the store API.
        ///
        /// Conforms to `Decodable` for JSON parsing and `@unchecked Sendable` for concurrency usage.
        /// It includes a subscription group ID, a group name, an array of products,
        /// and a flag indicating if this subscription group is currently active.
        struct SubscriptionGroup: Decodable, @unchecked Sendable {

            /// The subscription group ID from App Store Connect.
            var subscriptionGroupId: String?

            /// The name of the subscription group.
            var groupName: String?

            /// A collection of `Product` objects in this subscription group.
            var products: [Product]?

            /// A Boolean indicating whether this subscription group is currently active.
            var isCurrent: Bool?

            enum CodingKeys: String, CodingKey {
                case subscriptionGroupId = "sgi"
                case groupName = "gn"
                case products = "p"
                case isCurrent = "ic"
            }

            /// Initializes a new `SubscriptionGroup` instance by decoding from the given `Decoder`.
            ///
            /// - Parameter decoder: The decoder to read data from.
            /// - Throws: An error if any values are missing or if the data is corrupted.
            init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.subscriptionGroupId = try container.decodeIfPresent(String.self, forKey: .subscriptionGroupId)
                self.groupName = try container.decodeIfPresent(String.self, forKey: .groupName)
                self.products = try container.decodeIfPresent([Product].self, forKey: .products)
                self.isCurrent = try container.decodeIfPresent(Bool.self, forKey: .isCurrent)
            }

            // MARK: - Product

            /// A model representing a product within a subscription group.
            ///
            /// Conforms to `Decodable` so it can be parsed from JSON. It includes a unique identifier,
            /// a product identifier, a name, and a status.
            struct Product: Decodable {

                /// The unique identifier of the product (UUID v7).
                var id: String?

                /// The product identifier for this product (App Store Connect product ID).
                var productId: String?

                /// The name of the product.
                var name: String?

                /// The status of the product (e.g., READY_TO_SUBMIT, APPROVED).
                var status: String?

                enum CodingKeys: String, CodingKey {
                    case id
                    case productId = "pi"
                    case name = "n"
                    case status = "s"
                }

                /// Initializes a new `Product` instance by decoding from the given `Decoder`.
                ///
                /// - Parameter decoder: The decoder to read data from.
                /// - Throws: An error if any values are missing or if the data is corrupted.
                init(from decoder: any Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    self.id = try container.decodeIfPresent(String.self, forKey: .id)
                    self.productId = try container.decodeIfPresent(String.self, forKey: .productId)
                    self.name = try container.decodeIfPresent(String.self, forKey: .name)
                    self.status = try container.decodeIfPresent(String.self, forKey: .status)
                }
            }
        }

        // Paywall struct removed - no longer used
    }
}
