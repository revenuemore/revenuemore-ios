// 
//  See LICENSE.text for this project’s licensing information.
//
//  Entitlements.swift
//
//  Created by Bilal Durnagöl on 21.07.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// A class representing a collection of entitlements.
public class Entitlements: NSObject, @unchecked Sendable {

    /// An array containing all entitlements.
    public var allEntitlements: [Entitlement]

    /// An array containing only the active entitlements.
    public var activeEntitlements: [Entitlement]

    /// An array containing only the expired entitlements.
    public var expiredEntitlements: [Entitlement]

    /// A boolean indicating if there are any active entitlements.
    public var isPremium: Bool

    /// Initializes a new instance of ``Entitlements`` with the provided entitlements.
    ///
    /// - Parameter allEntitlements: An array containing all entitlements.
    public init(allEntitlements: [Entitlement]) {
        self.allEntitlements = allEntitlements
        self.activeEntitlements = allEntitlements.filter { $0.serviceStatus == .active }
        self.expiredEntitlements = allEntitlements.filter { $0.serviceStatus == .passive }
        self.isPremium = !activeEntitlements.isEmpty
    }
}
