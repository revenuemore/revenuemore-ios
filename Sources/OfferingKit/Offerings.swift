//
//  See LICENSE.text for this project's licensing information.
//
//  Offerings.swift
//
//  Created by Bilal Durnagöl on 3.09.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// Represents a collection of subscription groups and associated triggers.
///
/// This class encapsulates all subscription-related data, including a list of all offerings
/// and pointers to current active offerings.
public class Offerings: NSObject, @unchecked Sendable {

    // MARK: - Triggers (Disabled for now)
    // TODO: Re-enable when trigger feature is implemented
    // /// Optional array of `OfferingTrigger` objects related to the offerings.
    // /// Triggers may represent specific conditions or events associated with offerings.
    // public var triggers: [OfferingTrigger]?

    // /// Optional `OfferingTrigger` that represents the currently active trigger, if any.
    // /// This is determined by checking which trigger is marked as 'current'.
    // public var currentTrigger: OfferingTrigger?

    /// Array of all `Offering` objects.
    /// This array holds all offerings regardless of their current status.
    public var all: [Offering]

    /// Optional `Offering` that represents the currently active offering, if any.
    /// This is determined by checking which offering is marked as 'current'.
    public var currentOffering: Offering?

    /// Initializes a new `Offerings` instance with the specified offerings.
    ///
    /// - Parameters:
    ///   - offerings: An array of `Offering` objects to be managed by this instance.
    init(offerings: [Offering]) {
        self.all = offerings
        // Triggers disabled for now
        // self.triggers = triggers
        self.currentOffering = offerings.first(where: { $0.isCurrent == true })
        // self.currentTrigger = triggers?.first(where: { $0.isCurrent == true })
    }

    /// Retrieves an offering by its identifier.
    ///
    /// This method searches the array of all offerings for an offering matching the given identifier.
    /// - Parameter identifier: An optional string that uniquely identifies an offering.
    /// - Returns: An optional `Offering` object. Returns nil if no identifier is provided or if no matching offering is found.
    public func offering(with identifier: String?) -> Offering? {
        guard let identifier = identifier else {
            return nil // Returns nil if no identifier is provided.
        }

        let offering = all.first(where: {$0.identifier == identifier}) // Finds the first offering matching the identifier.
        return offering
    }
}
