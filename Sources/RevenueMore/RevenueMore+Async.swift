// 
//  See LICENSE.text for this project’s licensing information.
//
//  RevenueMore+Async.swift
//
//  Created by Bilal Durnagöl on 17.07.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

public extension RevenueMore {
    
    /// Asynchronously fetches all available offerings (packages/products).
    ///
    /// - Returns: An ``Offerings`` instance containing the available offerings.
    /// - Throws: If the fetch operation fails, this method may throw an error
    ///   (e.g., network or parsing issues).
    ///
    /// - Note: Only available on iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, or newer.
    /// - SeeAlso: ``RevenueMore/getOfferings(completion:)``
    ///
    /// **Example Usage**:
    /// ```swift
    /// Task {
    ///     do {
    ///         let offerings = try await RevenueMore.shared.getOfferings()
    ///         // Use the fetched offerings
    ///         print("Fetched Offerings: \(offerings)")
    ///     } catch {
    ///         // Handle the error
    ///         print("Failed to fetch offerings: \(error)")
    ///     }
    /// }
    /// ```
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    func getOfferings() async throws -> Offerings {
        try await self.offerings()
    }
    
    /// Asynchronously restores any previously purchased items for the current user.
    ///
    /// - Returns: An array of ``RevenueMorePaymentTransaction`` objects representing
    ///   restored purchases.
    /// - Throws: An error if the restore process fails for any reason (e.g., network
    ///   or StoreKit issues).
    ///
    /// - Note: Only available on iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, or newer.
    /// - SeeAlso: ``RevenueMore/restorePayment(completion:)``
    ///
    /// **Example Usage**:
    /// ```swift
    /// Task {
    ///     do {
    ///         let restoredTransactions = try await RevenueMore.shared.restorePayment()
    ///         // Process restored transactions
    ///         print("Restored Transactions: \(restoredTransactions)")
    ///     } catch {
    ///         // Handle the error
    ///         print("Failed to restore purchases: \(error)")
    ///     }
    /// }
    /// ```
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    @discardableResult
    func restorePayment() async throws -> [RevenueMorePaymentTransaction] {
        try await restoreAsync()
    }
    
    /// Asynchronously initiates a purchase flow for the specified product.
    ///
    /// - Parameters:
    ///   - product: A ``RevenueMoreProduct`` describing the product to be purchased.
    ///   - quantity: The number of items to purchase. Defaults to `1`.
    ///   - simulateAskToBuy: A Boolean indicating whether to simulate the Ask to Buy flow
    ///     in a sandbox environment. Defaults to `false`.
    /// - Returns: A ``RevenueMorePaymentTransaction`` indicating the result of the purchase.
    /// - Throws: An error if the purchase fails or is cancelled by the user.
    ///
    /// - Note: Only available on iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, or newer.
    /// - SeeAlso: ``RevenueMore/purchase(product:quantity:simulateAskToBuy:completion:)``
    ///
    /// **Example Usage**:
    /// ```swift
    /// Task {
    ///     do {
    ///         let transaction = try await RevenueMore.shared.purchase(product: someProduct)
    ///         // Handle successful purchase
    ///         print("Purchase successful: \(transaction.id)")
    ///     } catch {
    ///         // Handle the error
    ///         print("Purchase failed: \(error)")
    ///     }
    /// }
    /// ```
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    @discardableResult
    func purchase(
        product: RevenueMoreProduct,
        quantity: Int = 1,
        simulateAskToBuy: Bool = false
    ) async throws -> RevenueMorePaymentTransaction {
       return try await self.purchase(
        with: product,
        simulateAskToBuy: simulateAskToBuy,
        quantity: quantity
       )
    }
    
    /// Asynchronously listens for incoming payment transactions.
    ///
    /// Once a transaction is received or updated, this method will return with the
    /// ``RevenueMorePaymentTransaction`` data. If further transactions occur, you would call
    /// `listenPaymentTransactions()` again to receive subsequent updates.
    ///
    /// - Returns: A ``RevenueMorePaymentTransaction`` describing the processed or updated transaction.
    /// - Throws: An error if listening for transactions fails for any reason.
    ///
    /// - Note: Only available on iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, or newer.
    /// - SeeAlso: ``RevenueMore/listenPaymentTransactions(completion:)``
    ///
    /// **Example Usage**:
    /// ```swift
    /// Task {
    ///     do {
    ///         let transaction = try await RevenueMore.shared.listenPaymentTransactions()
    ///         // Handle the incoming transaction
    ///         print("Received Transaction: \(transaction.id)")
    ///     } catch {
    ///         // Handle the error
    ///         print("Failed to listen for transactions: \(error)")
    ///     }
    /// }
    /// ```
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    func listenPaymentTransactions() async throws -> RevenueMorePaymentTransaction {
       try await listenTransactions()
    }
    
    /// Asynchronously presents the system's "Manage Subscriptions" interface for the current user.
    ///
    /// - Throws: An error if showing the subscriptions management interface fails. This can happen
    ///   if the device cannot open the relevant App Store URL or if the platform is not supported.
    ///
    /// - Note: Only available on iOS 13.0, macOS 10.15 (and possibly xrOS).
    ///   Unavailable on watchOS and tvOS.
    /// - SeeAlso: ``RevenueMore/showManageSubscriptions(completion:)``
    ///
    /// **Example Usage**:
    /// ```swift
    /// Task {
    ///     do {
    ///         try await RevenueMore.shared.showManageSubscriptions()
    ///         print("Manage Subscriptions screen presented successfully.")
    ///     } catch {
    ///         print("Failed to present Manage Subscriptions screen: \(error)")
    ///     }
    /// }
    /// ```
    @available(iOS 13.0, macOS 10.15, *)
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    func showManageSubscriptions() async throws {
        try await showSubscriptionsAsync()
    }
    
    /// Asynchronously fetches and returns the current entitlements for the user.
    ///
    /// Entitlements typically represent access levels or subscription statuses that
    /// the user is entitled to based on their purchases.
    ///
    /// - Returns: An ``Entitlements`` object describing the user's active entitlements.
    /// - Throws: An error if fetching entitlements fails (e.g., network or backend errors).
    ///
    /// - Note: Only available on iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, or newer.
    /// - SeeAlso: ``RevenueMore/getEntitlements(completion:)``
    ///
    /// **Example Usage**:
    /// ```swift
    /// Task {
    ///     do {
    ///         let entitlements = try await RevenueMore.shared.getEntitlements()
    ///         // Use the fetched entitlements
    ///         print("User Entitlements: \(entitlements)")
    ///     } catch {
    ///         // Handle the error
    ///         print("Failed to fetch entitlements: \(error)")
    ///     }
    /// }
    /// ```
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    func getEntitlements() async throws -> Entitlements {
        try await getEntitlementsAsync()
    }
}
