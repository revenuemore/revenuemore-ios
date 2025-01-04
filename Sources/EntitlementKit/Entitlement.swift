// 
//  See LICENSE.text for this project’s licensing information.
//
//  Entitlement.swift
//
//  Created by Bilal Durnagöl on 21.07.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation
import StoreKit

/// A structure representing an entitlement for app store subscription.
public struct Entitlement: @unchecked Sendable {

    /// The status of the subscription renewal.
    public var renewStatus: Int?

    /// The price of the subscription .
    public var price: Double?

    /// The currency of the price.
    public var currency: String?

    /// The purchase date of the subscription , represented as a timestamp.
    public var purchaseDate: Double?

    /// The quantity of the subscription.
    public var quantity: Int?

    /// The start date of the subscription , represented as a timestamp.
    public var startDate: Double?

    /// The renewal date of the subscription , represented as a timestamp.
    public var renewalDate: Double?

    /// The current status of the service.
    /// - Note: `1` represents an active service, `0` represents a passive service.
    public var serviceStatus: ServiceStatus?

    /// The expiration date of the subscription, represented as a timestamp.
    public var expiresDate: Double?

    /// Product id of the subscription
    public var productId: String?

    /// Display name of the subscription
    public var displayName: String?

    /// Initializes a new instance of `Entitlement` with the provided values.
    ///
    /// - Parameters:
    ///   - productId: Product id of the subscription
    ///   - displayName: Display name of the subscription
    ///   - renewStatus: The status of the subscription renewal.
    ///   - price: The price of the subscription.
    ///   - currency: The currency of the price.
    ///   - purchaseDate: The purchase date of the subscription, represented as a timestamp.
    ///   - quantity: The quantity of the subscription .
    ///   - startDate: The start date of the subscription, represented as a timestamp.
    ///   - renewalDate: The renewal date of the subscription, represented as a timestamp.
    ///   - serviceStatus: The current status of the service.
    ///   - expiresDate: The expiration date of the subscription, represented as a timestamp.
    public init(
        productId: String? = nil,
        displayName: String? = nil,
        renewStatus: Int? = nil,
        price: Double? = nil,
        currency: String? = nil,
        purchaseDate: Double? = nil,
        quantity: Int? = nil,
        startDate: Double? = nil,
        renewalDate: Double? = nil,
        serviceStatus: ServiceStatus? = nil,
        expiresDate: Double? = nil
    ) {
        self.productId = productId
        self.renewStatus = renewStatus
        self.price = price
        self.currency = currency
        self.purchaseDate = purchaseDate
        self.quantity = quantity
        self.startDate = startDate
        self.renewalDate = renewalDate
        self.serviceStatus = serviceStatus
        self.expiresDate = expiresDate
        self.displayName = displayName
    }

    /// The status of the service.
    public enum ServiceStatus: Int, Decodable, UnknownCaseRepresentable, Hashable {

        public static var unknownCase: Entitlement.ServiceStatus {
            return passive
        }
        case active = 1
        case passive = 0
    }
}
