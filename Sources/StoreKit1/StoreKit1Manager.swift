// 
//  See LICENSE.text for this project’s licensing information.
//
//  StoreKitManager.swift
//
//  Created by Bilal Durnagöl on 12.04.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

#if os(watchOS)
import WatchKit
#else
import Foundation
import StoreKit
#endif

/// A manager class for handling StoreKit 1 operations, including fetching products and processing purchases.
///
/// `StoreKit1Manager` provides methods to fetch products via StoreKit 1, perform purchases,
/// restore transactions, and listen for payment transaction updates. It also integrates
/// user-specific logic through `userManager`.
internal class StoreKit1Manager: NSObject, @unchecked Sendable {

    // MARK: - Properties

    /// A local cache of `RM1Product` items fetched from the App Store.
    ///
    /// Upon a successful product fetch, the array is updated and can be used later
    /// for displaying product details or referencing them during purchase flows.
    var products = [RM1Product]()

    /// An object that handles fetching products using StoreKit 1.
    ///
    /// Conforms to `StoreKit1FetcherProtocol` to initiate product requests.
    private var storeKit1Fetcher: StoreKit1Fetcher
    
    /// An object that handles purchasing logic using StoreKit 1.
    ///
    /// Responsible for initiating purchases, listening to transaction updates,
    /// and restoring previous transactions.
    private var storeKit1Purchase: StoreKit1Purchase
    
    /// Manages user-specific data, including UUID and session state.
    ///
    /// Used to link purchases or restore operations to a particular user.
    private var userManager: UserManager

    // MARK: - Initialization

    /// Initializes a new `StoreKit1Manager` with the provided fetcher, purchase handler, and user manager.
    ///
    /// - Parameters:
    ///   - userManager: A `UserManager` instance to associate with this manager, storing user data.
    ///   - storeKit1Fetcher: A `StoreKit1Fetcher` responsible for fetching product data.
    ///   - storeKit1Purchase: A `StoreKit1Purchase` responsible for handling purchase flows.
    init(
        userManager: UserManager,
        storeKit1Fetcher: StoreKit1Fetcher,
        storeKit1Purchase: StoreKit1Purchase
    ) {
        self.storeKit1Fetcher = storeKit1Fetcher
        self.storeKit1Purchase = storeKit1Purchase
        self.userManager = userManager
    }

    // MARK: - StoreKit1 Availability

    /// A static helper method to check if the user can make payments (StoreKit).
    ///
    /// - Returns: A Boolean indicating whether the device (and user) is allowed to make purchases.
    /// - Note: Internally calls `StoreKit1Purchase.canMakePayments()`.
    static func canMakePayments() -> Bool {
        return StoreKit1Purchase.canMakePayments()
    }

    // MARK: - Product Fetching

    /// Fetches products from the App Store for the specified set of product identifiers.
    ///
    /// - Parameters:
    ///   - productIds: A set of product identifiers to look up in the App Store.
    ///   - completion: A closure that returns a `Result` containing:
    ///     - `[RM1Product]` on success, representing the products fetched.
    ///     - `RevenueMoreErrorInternal` on failure.
    ///
    /// **Behavior**:
    /// - On success, updates the local `products` array with the fetched results.
    /// - On failure, calls the completion closure with an appropriate error.
    func fetchProducts(
        with productIds: Set<String>,
        completion: @escaping @Sendable (Result<[RM1Product], RevenueMoreErrorInternal>) -> Void
    ) {
        storeKit1Fetcher.fetchProducts(with: productIds) { [weak self] result in
            switch result {
            case .success(let products):
                self?.products = products
                completion(.success(products))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Purchasing

    /// Initiates a purchase of a given `RM1Product`.
    ///
    /// - Parameters:
    ///   - product: The `RM1Product` object to be purchased.
    ///   - quantity: The number of items to purchase (must be >= 1).
    ///   - simulateAskToBuy: A Boolean indicating whether to simulate Ask to Buy in the sandbox environment.
    ///   - completion: A closure returning a `Result` with:
    ///     - `RM1PaymentTransaction` on success,
    ///     - `RevenueMoreErrorInternal` on failure.
    ///
    /// **Behavior**:
    /// - Validates that `quantity >= 1`. If not, it triggers a `fatalError`.
    /// - Calls through to `storeKit1Purchase.purchase(...)`, passing along the user’s UUID.
    func purchase(
        with product: RM1Product,
        quantity: Int,
        simulateAskToBuy: Bool,
        completion: @escaping @Sendable (Result<RM1PaymentTransaction, RevenueMoreErrorInternal>) -> Void
    ) {
        guard quantity >= 1 else {
            💥("Quantity must be at least 1.")
            fatalError("Quantity must be at least 1.")
        }
        let product = product
        storeKit1Purchase.purchase(
            product: product,
            uuid: userManager.uuid,
            quantity: quantity,
            simulateAskToBuy: simulateAskToBuy
        ) { @Sendable result in
            switch result {
            case .success(let transactions):
                completion(.success(transactions))
            case .failure(let error):
                let message = error.localizedDescription
                completion(.failure(.purhaseFailed(message)))
            }
        }
    }

    // MARK: - Transaction Listening

    /// Listens for payment transactions and notifies via the completion closure.
    ///
    /// - Parameter completion: A closure returning a `Result` containing:
    ///   - `RM1PaymentTransaction` on success,
    ///   - `RevenueMoreErrorInternal` on failure.
    ///
    /// **Usage**:
    /// Call this method to receive updates whenever new or updated transactions occur.
    func listenPaymentTransactions(completion: @escaping @Sendable (Result<RM1PaymentTransaction, RevenueMoreErrorInternal>) -> Void) {
        storeKit1Purchase.listenPaymentTransactions { result in
            switch result {
            case .success(let transactions):
                completion(.success(transactions))
            case .failure(let error):
                let message = error.localizedDescription
                completion(.failure(.listenPaymentFailed(message)))
            }
        }
    }

    // MARK: - Lifecycle Management

    /// Stops listening for payment transactions.
    ///
    /// Call this when you no longer need transaction updates, e.g., when the user logs out
    /// or the relevant part of your app is closed.
    func stopListenPaymentTrasactions() {
        storeKit1Purchase.stopTransactionListener()
    }
    
    /// Begins listening for payment transactions.
    ///
    /// Typically called after initializing or logging in a user, so that you can handle new
    /// transactions immediately.
    func startTransactionListener() {
        storeKit1Purchase.startTransactionListener()
    }

    // MARK: - Restoring Purchases

    /// Restores previously purchased items for the current user.
    ///
    /// - Parameter completion: A closure returning a `Result` containing:
    ///   - `[RM1PaymentTransaction]` on success,
    ///   - `RevenueMoreErrorInternal` on failure.
    ///
    /// **Usage**:
    /// Call this to restore non-consumable products or auto-renewable subscriptions.
    /// The user may be prompted for their App Store credentials.
    func restorePayment(completion: @escaping @Sendable (Result<[RM1PaymentTransaction], RevenueMoreErrorInternal>) -> Void) {
        storeKit1Purchase.restorePayment { result in
            switch result {
            case .success(let transactions):
                completion(.success(transactions))
            case .failure(let error):
                let message = error.localizedDescription
                completion(.failure(.restorePaymentFailed(message)))
            }
        }
    }

    // MARK: - Manage Subscriptions

    /// Presents the system's "Manage Subscriptions" interface on supported platforms.
    ///
    /// - Parameter completion: A closure that receives `true` if the manage subscriptions view
    ///   was successfully opened, or `false` if it could not be opened.
    ///
    /// **Platform Differences**:
    /// - **iOS/visionOS/macCatalyst**: Uses `UIApplication.shared.openManageSubscriptions(...)`.
    /// - **macOS**: Uses `NSApplication.shared.openManageSubscriptions(...)`.
    /// - **watchOS**: Uses `WKExtension.shared().openManageSubscriptions(...)`.
    ///
    /// - Warning: This method is annotated with `@MainActor` because it performs a UI-related action.
    @MainActor
    func showManageSubscriptions(completion: @escaping ((Bool) -> Void)) {
        #if os(iOS) || os(visionOS) || targetEnvironment(macCatalyst)
        UIApplication.shared.openManageSubscriptions(completion: completion)
        #elseif os(macOS)
        NSApplication.shared.openManageSubscriptions(completion: completion)
        #elseif os(watchOS)
        WKExtension.shared().openManageSubscriptions(completion: completion)
        #endif
    }
}
