// 
//  See LICENSE.text for this project’s licensing information.
//
//  RevenueMoreProduct.swift
//
//  Created by Bilal Durnagöl on 2.09.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// A unifying representation of a product, abstracting details from both StoreKit 1 and StoreKit 2.
///
/// ``RevenueMoreProduct`` conforms to `RevenueMoreProductProtocol` and uses an internal adapter
/// to delegate its functionality. Depending on how it is initialized, this adapter can be:
///  - `SKRevenueMoreProductAdapter` for StoreKit 1 (`RM1Product`)
///  - `RevenueMoreProductAdapter` for StoreKit 2 (`RM2Product`)
///
/// ``RevenueMoreProduct`` is also:
///  - `Hashable`: hashed by its `id`.
///  - `Sendable`: allows usage across concurrency boundaries.
public struct RevenueMoreProduct: Hashable, RevenueMoreProductProtocol, @unchecked Sendable {
    
    // MARK: - Hashable Conformance
    
    /// Combines the product's identifier into the hash value.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    /// Checks equality of two ``RevenueMoreProduct`` instances by comparing their identifiers.
    public static func == (lhs: RevenueMoreProduct, rhs: RevenueMoreProduct) -> Bool {
        lhs.id == rhs.id
    }
    
    // MARK: - Internal Adapter
    
    /// An internal protocol reference that implements `RevenueMoreProductProtocol`.
    ///
    /// This could be:
    /// - `RevenueMoreProductAdapter` for StoreKit 2 (`RM2Product`)
    /// - `SKRevenueMoreProductAdapter` for StoreKit 1 (`RM1Product`)
    private let adapter: RevenueMoreProductProtocol
    
    // MARK: - Initialization
    
    /// Initializes this product from a StoreKit 2 product (`RM2Product`).
    ///
    /// - Parameter product: A StoreKit 2 product to adapt.
    /// - Requires: iOS 15.0 or equivalent for StoreKit 2.
    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    init(product: RM2Product) {
        self.adapter = RevenueMoreProductAdapter(product: product)
    }

    /// Initializes this product from a StoreKit 1 product (`RM1Product`).
    ///
    /// - Parameter skProduct: A StoreKit 1 product to adapt.
    init(skProduct: RM1Product) {
        self.adapter = SKRevenueMoreProductAdapter(product: skProduct)
    }
    
    // MARK: - Descriptive Properties
    
    /// A textual description of the product, often its localized marketing text.
    public var description: String {
        return self.adapter.description
    }
    
    /// A user-facing name for this product, typically shown in your app's UI.
    public var displayName: String {
        return self.adapter.displayName
    }
    
    // MARK: - Pricing Properties
    
    /// The currency code (e.g., "USD", "EUR") for this product, or `nil` if unavailable.
    public var currencyCode: String? {
        return self.adapter.currencyCode
    }
    
    /// The price of the product as a `Decimal`.
    public var price: Decimal {
        return self.adapter.price
    }
    
    /// A human-readable string reflecting the product’s price (e.g., "$9.99").
    public var displayPrice: String {
        return self.adapter.displayPrice
    }
    
    /// A unique identifier (e.g., `"com.example.myapp.productId"`) for the product.
    public var id: String {
        return self.adapter.id
    }
    
    // MARK: - Subscription Period & Derived Prices
    
    /// The subscription period (e.g., monthly, yearly) if this product is a subscription.
    ///
    /// Returns `nil` for non-subscription products.
    /// - Requires: macOS 10.13.2 or newer.
    @available(macOS 10.13.2, *)
    public var period: RevenueMorePeriod? {
        return self.adapter.period
    }
    
    /// The computed price per week, if this product is a subscription.
    /// - Requires: macOS 10.13.2 or newer.
    @available(macOS 10.13.2, *)
    public var pricePerWeek: Decimal? {
        return self.adapter.pricePerWeek
    }
    
    /// The computed price per month, if this product is a subscription.
    /// - Requires: macOS 10.13.2 or newer.
    @available(macOS 10.13.2, *)
    public var pricePerMonth: Decimal? {
        return self.adapter.pricePerMonth
    }
    
    /// The computed price per year, if this product is a subscription.
    /// - Requires: macOS 10.13.2 or newer.
    @available(macOS 10.13.2, *)
    public var pricePerYear: Decimal? {
        return self.adapter.pricePerYear
    }
    
    /// The computed price per day, if this product is a subscription.
    /// - Requires: macOS 10.13.2 or newer.
    @available(macOS 10.13.2, *)
    public var pricePerDay: Decimal? {
        return self.adapter.pricePerDay
    }
    
    /// A user-friendly string for the product’s price per week, if applicable.
    /// - Requires: macOS 10.13.2 or newer.
    @available(macOS 10.13.2, *)
    public var displayPricePerWeek: String? {
        return self.adapter.displayPricePerWeek
    }
    
    /// A user-friendly string for the product’s price per month, if applicable.
    /// - Requires: macOS 10.13.2 or newer.
    @available(macOS 10.13.2, *)
    public var displayPricePerMonth: String? {
        return self.adapter.displayPricePerMonth
    }
    
    /// A user-friendly string for the product’s price per year, if applicable.
    /// - Requires: macOS 10.13.2 or newer.
    @available(macOS 10.13.2, *)
    public var displayPricePerYear: String? {
        return self.adapter.displayPricePerYear
    }
    
    /// A user-friendly string for the product’s price per day, if applicable.
    /// - Requires: macOS 10.13.2 or newer.
    @available(macOS 10.13.2, *)
    public var displayPricePerDay: String? {
        return self.adapter.displayPricePerDay
    }
    
    // MARK: - Additional StoreKit Properties
    
    /// Indicates if the product can be shared with family members (e.g., for subscription products).
    ///
    /// - Requires: iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, or newer.
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
    public var isFamilyShareable: Bool {
        return self.adapter.isFamilyShareable
    }
    
    /// The subscription group identifier, if available. Group IDs may be used to manage subscriptions across tiers.
    ///
    /// - Requires: iOS 12.0, macCatalyst 13.0, tvOS 12.0, macOS 10.14, watchOS 6.2, or newer.
    public var subscriptionGroupID: String? {
        return self.adapter.subscriptionGroupID
    }
    
    /// A `NumberFormatter` used for displaying price information, if available.
    public var priceFormatter: NumberFormatter? {
        return self.adapter.priceFormatter
    }
    
    // MARK: - StoreKit 1 & StoreKit 2 Accessors

    /// The underlying StoreKit 1 product if this instance was created from an `RM1Product`.
    ///
    /// - Returns: An `RM1Product` if StoreKit 1 is in use, otherwise `nil`.
    public var sk1Product: RM1Product? {
        return (self.adapter as? SKRevenueMoreProductAdapter)?.product
    }

    /// The underlying StoreKit 2 product if this instance was created from an `RM2Product`.
    ///
    /// - Returns: An `RM2Product` if StoreKit 2 is in use, otherwise `nil`.
    /// - Requires: iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, or newer.
    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    public var sk2Product: RM2Product? {
        return (self.adapter as? RevenueMoreProductAdapter)?.product
    }
}
