// 
//  See LICENSE.text for this project’s licensing information.
//
//  Offerings.swift
//
//  Created by Bilal Durnagöl on 3.09.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// Represents a collection of subscriptions and associated triggers.
///
/// This class encapsulates all subscription-related data, including a list of all subscriptions, optional triggers, and pointers to current active subscriptions and triggers.
public class Offerings: NSObject, @unchecked Sendable {

    /// Optional array of `Trigger` objects related to the subscriptions.
    /// Triggers may represent specific conditions or events associated with subscriptions.
    public var triggers: [OfferingTrigger]?

    /// Array of all `Subscription` objects.
    /// This array holds all subscriptions regardless of their current status.
    public var all: [Offering]

    /// Optional `Subscription` that represents the currently active subscription, if any.
    /// This is determined by checking which subscription is marked as 'current'.
    public var currentOffering: Offering?

    /// Optional `Trigger` that represents the currently active trigger, if any.
    /// This is determined by checking which trigger is marked as 'current'.
    public var currentTrigger: OfferingTrigger?

    /// Initializes a new `Subscriptions` instance with the specified subscriptions and optional triggers.
    ///
    /// - Parameters:
    ///   - subscriptions: An array of `Subscription` objects to be managed by this instance.
    ///   - triggers: An optional array of `Trigger` objects associated with the subscriptions.
    init(offerings: [Offering], triggers: [OfferingTrigger]?) {
        self.all = offerings
        self.triggers = triggers
        self.currentOffering = offerings.first(where: { $0.isCurrent == true })
        self.currentTrigger = triggers?.first(where: { $0.isCurrent == true })
    }

    /// Retrieves a subscription by its identifier.
    ///
    /// This method searches the array of all subscriptions for a subscription matching the given identifier.
    /// - Parameter identifier: An optional string that uniquely identifies a subscription.
    /// - Returns: An optional `Subscription` object. Returns nil if no identifier is provided or if no matching subscription is found.
    public func offering(with identifier: String?) -> Offering? {
        guard let identifier = identifier else {
            return nil // Returns nil if no identifier is provided.
        }

        let offering = all.first(where: {$0.identifier == identifier}) // Finds the first subscription matching the identifier.
        return offering
    }
}
