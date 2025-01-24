// 
//  See LICENSE.text for this project’s licensing information.
//
//  RevenueMoreProductAdapter.swift
//
//  Created by Bilal Durnagöl on 2.09.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// An adapter class that implements `RevenueMoreProductProtocol` for StoreKit 2 products (`RM2Product`).
///
/// `RevenueMoreProductAdapter` wraps an `RM2Product`, exposing properties and derived values
/// in a common interface defined by `RevenueMoreProductProtocol`. This allows your app
/// to handle StoreKit 2 products uniformly alongside other product representations.
///
/// **Concurrency**:
/// - Marked `@unchecked Sendable` because it holds an `RM2Product`, which may have
///   its own concurrency constraints. Ensure safe usage across concurrency boundaries.
@available(iOS 15.0, tvOS 15.0, macOS 12.0, *)
internal class RevenueMoreProductAdapter: @unchecked Sendable, RevenueMoreProductProtocol {
    
    // MARK: - Properties
    
    /// The StoreKit 2 product being adapted.
    ///
    /// `RM2Product` is assumed to wrap or correspond to a `StoreKit.Product`,
    /// providing fields like `id`, `price`, `displayName`, and subscription details.
    let product: RM2Product
    
    // MARK: - Initialization

    /// Creates an adapter for a StoreKit 2 product (`RM2Product`).
    ///
    /// - Parameter product: The StoreKit 2 product to be adapted.
    init(product: RM2Product) {
        self.product = product
    }
    
    // MARK: - RevenueMoreProductProtocol Conformance
    
    /// A localized or descriptive string for this product, typically its marketing description.
    var description: String {
        return product.description
    }
    
    /// A user-friendly name for this product, generally shown in the app’s UI.
    var displayName: String {
        return product.displayName
    }
    
    /// The currency code (e.g., `"USD"`, `"EUR"`) for this product, if available.
    var currencyCode: String? {
        return product.priceFormatStyle.currencyCode
    }
    
    /// The raw price of the product as a `Decimal`.
    var price: Decimal {
        return product.price
    }
    
    /// A localized, display-friendly version of the product’s price (e.g., "$4.99").
    var displayPrice: String {
        return product.displayPrice
    }
    
    /// A unique identifier for the product (e.g., `"com.example.myapp.monthly_subscription"`).
    var id: String {
        return product.id
    }
    
    /// Indicates whether family sharing is enabled for this product.
    ///
    /// For a subscription, this typically corresponds to whether
    /// the subscription is shareable within an Apple Family Sharing group.
    var isFamilyShareable: Bool {
        return product.isFamilyShareable
    }
    
    /// The subscription group identifier, if this product is part of a subscription group.
    ///
    /// May be `nil` if the product is not subscription-based or if no group ID is available.
    var subscriptionGroupID: String? {
        return product.subscription?.subscriptionGroupID
    }
    
    /// A `RevenueMorePeriod` describing the subscription’s renewal frequency, if applicable.
    ///
    /// Translates the StoreKit 2 `SubscriptionPeriod` into a unified `RevenueMorePeriod`.
    /// Returns `nil` if this product is not a subscription.
    var period: RevenueMorePeriod? {
        if let subscriptionPeriod = product.subscription?.subscriptionPeriod {
            return RevenueMorePeriod(subscriptionPeriod)
        } else {
            return nil
        }
    }
    
    /// The computed price per week for this subscription, if a period is available.
    var pricePerWeek: Decimal? {
        return period?.pricePerWeek(with: price)
    }
    
    /// The computed price per month for this subscription, if a period is available.
    var pricePerMonth: Decimal? {
        return period?.pricePerMonth(with: price)
    }
    
    /// The computed price per year for this subscription, if a period is available.
    var pricePerYear: Decimal? {
        return period?.pricePerYear(with: price)
    }
    
    /// The computed price per day for this subscription, if a period is available.
    var pricePerDay: Decimal? {
        return period?.pricePerDay(with: price)
    }
    
    /// A display-friendly string for the product’s price per week, if calculable.
    var displayPricePerWeek: String? {
        priceFormatter?.string(for: pricePerWeek)
    }
    
    /// A display-friendly string for the product’s price per month, if calculable.
    var displayPricePerMonth: String? {
        priceFormatter?.string(for: pricePerMonth)
    }
    
    /// A display-friendly string for the product’s price per year, if calculable.
    var displayPricePerYear: String? {
        priceFormatter?.string(for: pricePerYear)
    }
    
    /// A display-friendly string for the product’s price per day, if calculable.
    var displayPricePerDay: String? {
        priceFormatter?.string(for: pricePerDay)
    }
    
    /// A number formatter configured to display currency values using the product’s currency code.
    ///
    /// Used for generating display-friendly strings (e.g., `$4.99`).
    var priceFormatter: NumberFormatter? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = product.priceFormatStyle.currencyCode
        return formatter
    }
}
