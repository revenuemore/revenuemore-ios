// 
//  See LICENSE.text for this project’s licensing information.
//
//  RevenueMorePeriod.swift
//
//  Created by Bilal Durnagöl on 11.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation
import StoreKit

/// A representation of the duration between subscription renewals.
///
/// This struct holds two pieces of information:
/// - `value`: The length of the subscription period (e.g., `1`, `2`).
/// - `unit`: The [`Unit`](x-source-tag://RevenueMorePeriod.Unit) that specifies the time unit (e.g., `.day`, `.month`).
///
/// `RevenueMorePeriod` conforms to `Sendable`, `Equatable`, `Hashable`, and `Decodable`, enabling
/// safe use across concurrency boundaries, easy comparison, usage in sets, and JSON decoding.
extension RevenueMorePeriod: Equatable, Hashable, Decodable { }

/// A nested enumeration within `RevenueMorePeriod` specifying the unit of time used in a subscription period.
///
/// Possible values are `day`, `week`, `month`, `year`, and `unknown`.
/// Conforms to `String` (raw values), `UnknownCaseRepresentable` (handling unknown cases), `Equatable`, `Hashable`, and `Decodable`.
extension RevenueMorePeriod.Unit: Equatable, Hashable, Decodable { }

/// Represents the duration of time between subscription renewals.
///
/// `RevenueMorePeriod` contains:
/// - `value`: The numeric length of the period.
/// - `unit`: A [`Unit`](x-source-tag://RevenueMorePeriod.Unit) describing which time unit (day, week, month, year).
///
/// This struct is used to unify StoreKit 1 and StoreKit 2 subscription periods within the RevenueMore system.
public struct RevenueMorePeriod: @unchecked Sendable {
    /// The length of the subscription period (e.g., `1`, `2`, etc.).
    public let value: Int
    
    /// The time unit of the subscription period (e.g., `.day`, `.month`, etc.).
    public let unit: Unit
}

// MARK: - Initializers for StoreKit 1 and StoreKit 2

extension RevenueMorePeriod {
    /// Initializes a `RevenueMorePeriod` using a StoreKit 2 subscription period.
    ///
    /// - Parameter value: A `RM2Product.SubscriptionPeriod` instance (presumably bridging or wrapping StoreKit 2’s `SubscriptionPeriod`).
    /// - Requires: iOS 15.0, macOS 12.0, tvOS 15.0 or visionOS 1.0.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, visionOS 1.0, *)
    init(_ value: RM2Product.SubscriptionPeriod) {
        self.value = value.value
        self.unit = .init(value.unit)
    }
    
    /// Initializes a `RevenueMorePeriod` using a StoreKit 1 subscription period.
    ///
    /// - Parameter value: An `SKProductSubscriptionPeriod`, which includes `numberOfUnits` and `unit`.
    /// - Requires: macOS 10.13.2 or newer.
    @available(macOS 10.13.2, *)
    init (_ value: SKProductSubscriptionPeriod) {
        self.value = value.numberOfUnits
        self.unit = .init(value.unit)
    }
}

// MARK: - Unit Definition

extension RevenueMorePeriod {
    /// The unit of time for a subscription period, such as `day`, `week`, `month`, or `year`.
    ///
    /// - Tag: RevenueMorePeriod.Unit
    public enum Unit: String, UnknownCaseRepresentable {
        
        /// Provides the `unknown` case when decoding or handling unknown raw values.
        public static var unknownCase: RevenueMorePeriod.Unit {
            return unknown
        }
        
        /// The subscription repeats daily.
        case day
        
        /// The subscription repeats weekly.
        case week
        
        /// The subscription repeats monthly.
        case month
        
        /// The subscription repeats yearly.
        case year
        
        /// An unknown or unrecognized subscription period unit.
        case unknown
    }
}

// MARK: - Converting StoreKit Period Units

extension RevenueMorePeriod.Unit {
    /// Initializes a `RevenueMorePeriod.Unit` from a StoreKit 2 subscription period unit.
    ///
    /// - Parameter value: A `RM2Product.SubscriptionPeriod.Unit`.
    /// - Requires: iOS 15.0, macOS 12.0, tvOS 15.0, visionOS 1.0, or newer.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, visionOS 1.0, *)
    init(_ value: RM2Product.SubscriptionPeriod.Unit) {
        self = switch value {
        case .day: .day
        case .week: .week
        case .month: .month
        case .year: .year
        @unknown default:
            .unknown
        }
    }
    
    /// Initializes a `RevenueMorePeriod.Unit` from a StoreKit 1 subscription period unit.
    ///
    /// - Parameter value: An `RM1Product.PeriodUnit`.
    /// - Requires: macOS 10.13.2 or newer.
    @available(macOS 10.13.2, *)
    init(_ value: RM1Product.PeriodUnit) {
        self = switch value {
        case .day: .day
        case .week: .week
        case .month: .month
        case .year: .year
        @unknown default:
            .unknown
        }
    }
}

// MARK: - Day Count and Price Calculations

extension RevenueMorePeriod {
    
    /// The approximate day count represented by this subscription period.
    ///
    /// - Returns:
    ///   - `1` for `.day`,
    ///   - `7` for `.week`,
    ///   - `30` for `.month`,
    ///   - `365` for `.year`,
    ///   - `0` for `.unknown`.
    var dayCount: Int {
        switch self.unit {
        case .day:
            return 1
        case .week:
            return 7
        case .month:
            return 30
        case .year:
            return 365
        case .unknown:
            return 0
        }
    }
    
    /// Calculates a price-per-day figure from a given total price over this subscription period.
    ///
    /// - Parameter price: The total price for the subscription’s period.
    /// - Returns: A new `Decimal` representing how much this product costs per day, truncated to 2 decimal places.
    func pricePerDay(with price: Decimal) -> Decimal {
        let unit = Decimal(self.dayCount * self.value)
        return roundingPrice(with: price * Constants.Period.DayCount.day, by: unit)
    }
    
    /// Calculates a price-per-week figure from a given total price over this subscription period.
    ///
    /// - Parameter price: The total price for the subscription’s period.
    /// - Returns: A `Decimal` representing the cost per week, truncated to 2 decimal places.
    func pricePerWeek(with price: Decimal) -> Decimal {
        let unit = Decimal(self.dayCount * self.value)
        return roundingPrice(with: price * Constants.Period.DayCount.week, by: unit)
    }
    
    /// Calculates a price-per-month figure from a given total price over this subscription period.
    ///
    /// - Parameter price: The total price for the subscription’s period.
    /// - Returns: A `Decimal` representing the cost per month, truncated to 2 decimal places.
    func pricePerMonth(with price: Decimal) -> Decimal {
        let unit = Decimal(self.dayCount * self.value)
        return roundingPrice(with: price * Constants.Period.DayCount.month, by: unit)
    }
    
    /// Calculates a price-per-year figure from a given total price over this subscription period.
    ///
    /// - Parameter price: The total price for the subscription’s period.
    /// - Returns: A `Decimal` representing the cost per year, truncated to 2 decimal places.
    func pricePerYear(with price: Decimal) -> Decimal {
        let unit = Decimal(self.dayCount * self.value)
        return roundingPrice(with: price * Constants.Period.DayCount.year, by: unit)
    }
    
    /// An `NSDecimalNumberHandler` used to truncate decimal values to 2 places (e.g., `XX.XX`).
    static let roundingHandler = NSDecimalNumberHandler(
        roundingMode: .down,
        scale: 2,
        raiseOnExactness: false,
        raiseOnOverflow: false,
        raiseOnUnderflow: false,
        raiseOnDivideByZero: false
    )
    
    /// A helper function for dividing one price by another, truncating the result to 2 decimal places.
    ///
    /// - Parameters:
    ///   - price: The numerator in the division (e.g., total price).
    ///   - unit: The denominator (e.g., total number of days or day-equivalent units).
    /// - Returns: A `Decimal` representing the computed rate, truncated to 2 decimal places.
    func roundingPrice(with price: Decimal, by unit: Decimal) -> Decimal {
        return (price as NSDecimalNumber)
            .dividing(by: unit as NSDecimalNumber,
                      withBehavior: Self.roundingHandler) as Decimal
    }
}
