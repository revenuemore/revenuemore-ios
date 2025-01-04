// 
//  See LICENSE.text for this project’s licensing information.
//
//  Offering.swift
//
//  Created by Bilal Durnagöl on 3.09.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// Represents a single offering, detailing its identifier, associated products, and its current status.
///
/// This struct defines a subscription model within a system that manages products and subscriptions. It includes an identifier for the subscription, a list of associated products (which might be nil if no products are associated), and a boolean indicating whether this subscription is currently active.
public struct Offering: @unchecked Sendable {
    
    /// A unique identifier for the subscription.
    /// This identifier is used to distinctly recognize and manage this specific subscription within the system.
    public let identifier: String
    
    /// An optional array of ``RevenueMoreProduct`` objects associated with this subscription.
    /// These products represent what the subscriber has access to under this subscription. The array can be nil if no products are currently linked to the subscription.
    public let products: [RevenueMoreProduct]?

    /// A boolean value indicating whether this subscription is the current active subscription.
    /// This is used to easily identify and handle the subscription currently in use by the subscriber.
    public let isCurrent: Bool

    /// Initializes a new instance of `Subscription`.
    ///
    /// - Parameters:
    ///   - identifier: The unique identifier for the subscription.
    ///   - products: An optional array of ``RevenueMoreProduct`` objects linked to the subscription. Pass nil if there are no products associated.
    ///   - isCurrent: A boolean value indicating whether this subscription is currently active.
    public init(identifier: String, products: [RevenueMoreProduct]?, isCurrent: Bool) {
        self.identifier = identifier
        self.products = products
        self.isCurrent = isCurrent
    }
}
