// 
//  See LICENSE.text for this project’s licensing information.
//
//  RevenueMoreProductProtocol.swift
//
//  Created by Bilal Durnagöl on 2.09.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// A protocol describing the common properties and behavior of a purchasable product.
///
/// Conforming types must provide price details, localized display properties,
/// subscription metadata (if applicable), and other StoreKit-related information.
/// This protocol is agnostic to whether the underlying product is from StoreKit 1 or StoreKit 2.
///
/// **Concurrency**:
/// - Conforms to `Sendable` so that instances can be safely passed across concurrency boundaries.
internal protocol RevenueMoreProductProtocol: Sendable {
    
    // MARK: - Descriptive Properties
    
    /// A descriptive text for the product.
    ///
    /// This description’s language is determined by the storefront that the user’s device is connected to,
    /// not the user’s preferred device language.
    ///
    /// **Example**:
    /// ```swift
    /// let productDescription = product.description
    /// print(productDescription)
    /// ```
    var description: String { get }
    
    /// A user-friendly name for the product.
    ///
    /// This name’s language is determined by the storefront that the user’s device is connected to,
    /// not the device’s preferred language.
    ///
    /// **Example**:
    /// ```swift
    /// let displayName = product.displayName
    /// showInUI(displayName)
    /// ```
    var displayName: String { get }
    
    // MARK: - Pricing
    
    /// The currency code for the product's price (e.g., `"USD"`, `"EUR"`) if known.
    ///
    /// Returns `nil` if the currency code is unavailable.
    var currencyCode: String? { get }
    
    /// The raw, decimal representation of the product’s cost in local currency.
    ///
    /// Use `displayPrice` or `priceFormatter` to show a localized, user-friendly string.
    ///
    /// **Related Symbols**:
    /// - `pricePerWeek`
    /// - `pricePerMonth`
    /// - `pricePerYear`
    /// - `pricePerDay`
    var price: Decimal { get }
    
    /// A string representation of the product’s price, formatted for display to customers.
    ///
    /// For a more flexible or customized display, see `priceFormatter`.
    var displayPrice: String { get }
    
    // MARK: - Identification
    
    /// A string that identifies the product in the App Store (e.g., `"com.company.myapp.subscription_monthly"`).
    var id: String { get }
    
    // MARK: - Family Sharing
    
    /// Indicates whether the product is sharable via Family Sharing in the App Store.
    ///
    /// If `true`, family group members can also use the product once purchased (where applicable).
    /// Configure family sharing in App Store Connect. For more info, see
    /// [Turn on Family Sharing for in-app purchases](https://support.apple.com/en-us/HT201079).
    ///
    /// - Requires: iOS 14.0, macOS 11.0, tvOS 14.0, or later.
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
    var isFamilyShareable: Bool { get }
    
    // MARK: - Subscription Group
    
    /// The identifier of the subscription group if this product is an auto-renewable subscription.
    ///
    /// All auto-renewable subscriptions must belong to a group created in App Store Connect.
    /// Returns `nil` for non-subscription products or if not configured.
    ///
    /// - Requires: macCatalyst 13.0, tvOS 12.0, macOS 10.14, watchOS 6.2, or later.
    @available(macCatalyst 13.0, tvOS 12.0, macOS 10.14, watchOS 6.2, *)
    var subscriptionGroupID: String? { get }
    
    // MARK: - Price Formatting
    
    /// A formatter that can convert the product’s price into a localized currency string.
    ///
    /// - Note: A new formatter may be created for each product, which can affect performance.
    /// - Note: For StoreKit 2 products prior to iOS 16, this may be `nil` if the currency code can’t be determined.
    ///         Otherwise, it won’t be `nil`.
    var priceFormatter: NumberFormatter? { get }
    
    // MARK: - Subscription Period and Derived Prices
    
    /// The subscription period, if applicable, indicating how often the subscription renews (e.g., monthly, yearly).
    ///
    /// Returns `nil` if this product is not a subscription.
    /// - Requires: macOS 10.13.2 or later.
    @available(macOS 10.13.2, *)
    var period: RevenueMorePeriod? { get }
    
    /// The computed cost per week, if this product is a subscription.
    /// - Requires: macOS 10.13.2 or later.
    @available(macOS 10.13.2, *)
    var pricePerWeek: Decimal? { get }
    
    /// The computed cost per month, if this product is a subscription.
    /// - Requires: macOS 10.13.2 or later.
    @available(macOS 10.13.2, *)
    var pricePerMonth: Decimal? { get }
    
    /// The computed cost per year, if this product is a subscription.
    /// - Requires: macOS 10.13.2 or later.
    @available(macOS 10.13.2, *)
    var pricePerYear: Decimal? { get }
    
    /// The computed cost per day, if this product is a subscription.
    /// - Requires: macOS 10.13.2 or later.
    @available(macOS 10.13.2, *)
    var pricePerDay: Decimal? { get }
    
    /// A display-friendly string for the computed cost per week, if this product is a subscription.
    /// - Requires: macOS 10.13.2 or later.
    @available(macOS 10.13.2, *)
    var displayPricePerWeek: String? { get }
    
    /// A display-friendly string for the computed cost per month, if this product is a subscription.
    /// - Requires: macOS 10.13.2 or later.
    @available(macOS 10.13.2, *)
    var displayPricePerMonth: String? { get }
    
    /// A display-friendly string for the computed cost per year, if this product is a subscription.
    /// - Requires: macOS 10.13.2 or later.
    @available(macOS 10.13.2, *)
    var displayPricePerYear: String? { get }
    
    /// A display-friendly string for the computed cost per day, if this product is a subscription.
    /// - Requires: macOS 10.13.2 or later.
    @available(macOS 10.13.2, *)
    var displayPricePerDay: String? { get }
}
