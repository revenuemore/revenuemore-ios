// 
//  See LICENSE.text for this project’s licensing information.
//
//  UnknownCaseRepresentable.swift
//
//  Created by Bilal Durnagöl on 21.07.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// A protocol that provides a default unknown case for enums.
///
/// This protocol is useful for enums that need to handle unknown cases,
/// typically when working with external data sources that might introduce
/// new values over time.
///
/// Requirements:
/// - The enum must conform to `RawRepresentable` and `CaseIterable`.
/// - The `RawValue` type must be `Equatable`.
public protocol UnknownCaseRepresentable: RawRepresentable, CaseIterable where RawValue: Equatable {

    /// The default unknown case for the enum.
    ///
    /// Enums conforming to this protocol must provide a static property
    /// that represents an unknown case. This is used as a fallback when
    /// initializing the enum with an unknown raw value.
    static var unknownCase: Self { get }
}

/// An extension to provide a default implementation for the initializer.
///
/// This extension provides an initializer that attempts to create an instance
/// of the enum from a raw value. If the raw value does not match any of the
/// known cases, the initializer assigns the `unknownCase` value.
extension UnknownCaseRepresentable {

    /// Initializes an enum case from a raw value.
    ///
    /// If the raw value does not correspond to any known cases, the
    /// `unknownCase` value is assigned.
    ///
    /// - Parameter rawValue: The raw value to initialize from.
    public init(rawValue: RawValue) {
        let value = Self.allCases.first(where: { $0.rawValue == rawValue })
        self = value ?? Self.unknownCase
    }
}
