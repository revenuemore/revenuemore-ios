// 
//  See LICENSE.text for this project’s licensing information.
//
//  Constants.swift
//
//  Created by Bilal Durnagöl on 19.03.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

// swiftlint:disable identifier_name

/// A container for various application-wide constants.
///
/// `Constants` serves as a namespace-like structure for grouping static values that
/// may be used across different parts of your application or library.
internal class Constants { }

// MARK: - Error Description

extension Constants {
    /// A namespace for queue-related constants.
    ///
    /// Use the static properties in `Queue` to reference queue identifiers for
    /// StoreKit1 operations in a consistent manner across the codebase.
    struct Queue {
        /// A queue identifier for the StoreKit1 fetcher.
        ///
        /// This constant is used to dispatch or manage tasks related to
        /// fetching product information using StoreKit1.
        static let FETCHER_SK1: String = "RevenueMore.StoreKit1.Fetcher"
        
        /// A queue identifier for the StoreKit1 purchase flow.
        ///
        /// This constant is used to handle tasks related to
        /// processing purchases using StoreKit1.
        static let PURCHASE_SK1: String = "RevenueMore.StoreKit1.Purchase"
    }
    
    /// A namespace for constants pertaining to time periods.
    ///
    /// `Period` includes subdivisions that group time-related constants.
    /// In this example, `DayCount` stores values that represent the number
    /// of days for common intervals (day, week, month, year).
    struct Period {
        
        /// A collection of day-based constants for common time intervals.
        ///
        /// Each constant represents the approximate or average number of days
        /// in the specified interval (e.g., a week is 7 days, a year is 365 days).
        enum DayCount {
            /// The decimal value representing one day.
            static let day: Decimal = 1
            
            /// The decimal value representing one week (7 days).
            static let week: Decimal = 7
            
            /// The decimal value representing one month (30 days).
            static let month: Decimal = 30
            
            /// The decimal value representing one year (365 days).
            static let year: Decimal = 365
        }
    }
}

// swiftlint:enable identifier_name
