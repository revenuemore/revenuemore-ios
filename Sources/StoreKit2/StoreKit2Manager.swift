// 
//  See LICENSE.text for this project’s licensing information.
//
//  StoreKit2Manager.swift
//
//  Created by Bilal Durnagöl on 21.05.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// A manager class that orchestrates StoreKit 2 operations, such as fetching products,
/// making purchases, and restoring transactions.
///
/// `StoreKit2Manager` holds references to `StoreKit2Fetcher` and `StoreKit2Purchase`,
/// leveraging these classes to perform StoreKit 2–based tasks. It also integrates user
/// logic from a `UserManager`.
///
/// **Concurrency**:
/// - Marked `@unchecked Sendable` to allow use across concurrency boundaries.
///   Ensure thread-safety within `StoreKit2Fetcher` and `StoreKit2Purchase`.
@available(iOS 15.0, tvOS 15.0, macOS 12.0, *)
internal class StoreKit2Manager: NSObject, @unchecked Sendable {

    // MARK: - Properties

    /// An instance responsible for fetching products from the App Store using StoreKit 2.
    private var storeKit2Fetcher: StoreKit2Fetcher

    /// An instance responsible for handling purchases and restoring transactions via StoreKit 2.
    private var storeKit2Purchase: StoreKit2Purchase

    /// A manager for user data, such as UUIDs and session state.
    private var userManager: UserManager

    // MARK: - Initialization

    /// Creates a new `StoreKit2Manager` with the specified dependencies.
    ///
    /// - Parameters:
    ///   - userManager: A `UserManager` that provides user session information.
    ///   - storeKit2Fetcher: A `StoreKit2Fetcher` used for retrieving products.
    ///   - storeKit2Purchase: A `StoreKit2Purchase` used for performing and managing purchases.
    init(
        userManager: UserManager,
        storeKit2Fetcher: StoreKit2Fetcher,
        storeKit2Purchase: StoreKit2Purchase
    ) {
        self.storeKit2Fetcher = storeKit2Fetcher
        self.storeKit2Purchase = storeKit2Purchase
        self.userManager = userManager
    }

    // MARK: - Public Methods

    /// Fetches products for the specified set of product identifiers using StoreKit 2.
    ///
    /// - Parameter productIds: A set of product IDs (e.g., `["com.example.product1"]`).
    /// - Returns: An array of `RM2Product` objects that match the given IDs.
    /// - Throws:
    ///   - `RevenueMoreErrorInternal.notFoundProductIDs` if `productIds` is empty.
    ///   - `RevenueMoreErrorInternal.fetchProductFailed` if StoreKit fails to return products.
    ///   - `RevenueMoreErrorInternal.notFoundStoreProduct` if no products are found.
    /// - Note: This method calls through to `storeKit2Fetcher.fetchProducts(with:)`.
    func fetchProducts(with productIds: Set<String>) async throws -> [RM2Product] {
        return try await storeKit2Fetcher.fetchProducts(with: productIds)
    }
    
    /// Indicates whether the current device and user can make StoreKit payments.
    ///
    /// - Returns: A Boolean value indicating if in-app purchases are allowed.
    /// - Note: Internally calls `StoreKit2Purchase.canMakePayments()`.
    static func canMakePayments() -> Bool {
        return StoreKit2Purchase.canMakePayments()
    }

    /// Asynchronously purchases a StoreKit 2 product with optional Ask to Buy simulation.
    ///
    /// - Parameters:
    ///   - product: The `RM2Product` to be purchased.
    ///   - simulateAskToBuy: A Boolean indicating whether to simulate Ask to Buy flow in sandbox environments.
    ///   - quantity: The quantity of the product to purchase (must be >= 1).
    /// - Returns: An `RM2PaymentTransaction` object representing the transaction.
    /// - Throws:
    ///   - A runtime error (`fatalError`) if `quantity < 1`.
    ///   - Any error thrown by `storeKit2Purchase.purchase(...)`.
    func purchase(product: RM2Product, simulateAskToBuy: Bool, quantity: Int) async throws -> RM2PaymentTransaction {
        guard quantity >= 1 else {
            💥("Quantity must be at least 1.")
            fatalError("Quantity must be at least 1.")
        }
        do {
            let purchase = try await storeKit2Purchase.purchase(
                product: product,
                uuid: userManager.uuid,
                simulateAskToBuy: simulateAskToBuy,
                quantity: quantity
            )
            return purchase
        } catch {
            throw error
        }
    }

    /// Asynchronously restores previously purchased items using StoreKit 2.
    ///
    /// - Returns: An array of `RM2PaymentTransaction` objects representing restored transactions.
    /// - Throws: Any error thrown by `storeKit2Purchase.restorePayment()`.
    func restorePayment() async throws -> [RM2PaymentTransaction] {
        try await storeKit2Purchase.restorePayment()
    }

    /// Begins listening for transaction updates using the `StoreKit2Purchase` instance.
    ///
    /// - Parameter completion: A closure of type `TransactionUpdate` that receives updated transactions
    ///   or errors as they occur.
    /// - Note: Forwards the call to `storeKit2Purchase.listenPaymentTransactions(completion:)`.
    func listenPaymentTransactions(completion: @escaping TransactionUpdate) {
        storeKit2Purchase.listenPaymentTransactions(completion: completion)
    }

    /// Displays the subscription management interface on supported platforms (iOS 15+, macOS 12.0+).
    ///
    /// - Throws:
    ///   - `RevenueMoreErrorInternal.notFoundWindowScene` if no valid `UIWindowScene` is found on iOS.
    ///   - `RevenueMoreErrorInternal.notShowManageSubscriptions(errorDescription)` if the interface fails to present.
    /// - Note:
    ///   - Not available on watchOS and tvOS, due to `@available` annotations.
    ///   - Uses `storeKit2Fetcher.showManageSubscriptions()` internally.
    @available(iOS 15.0, *)
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    func showManageSubscriptions() async throws {
        try await storeKit2Fetcher.showManageSubscriptions()
    }
}
