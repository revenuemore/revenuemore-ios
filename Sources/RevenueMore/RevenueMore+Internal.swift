// 
//  See LICENSE.text for this project’s licensing information.
//
//  RevenueMore+Internal.swift
//
//  Created by Bilal Durnagöl on 26.05.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

internal extension RevenueMore {

    // MARK: - Non-Async User Management
    
    /// Logs in a user with the given user ID and updates the entitlements accordingly.
    ///
    /// - Parameters:
    ///   - userId: The unique identifier of the user to log in with.
    ///   - completionHandler: A closure that gets called once the login process completes.
    ///
    /// **Implementation Details**:
    /// Calls `entitlementManager.updateUserId(userId:completion:)` to persist and update
    /// the user’s session. After a successful update, the user’s entitlements can be refreshed.
    func login(userId: String, completionHandler: @escaping @Sendable () -> Void) {
        entitlementManager.updateUserId(userId: userId, completion: completionHandler)
    }
    
    /// Logs out the currently active user session and starts an anonymous session.
    ///
    /// **Implementation Details**:
    /// - Calls `userManager.logout()` to clear the current user’s data and retrieve an anonymous user.
    /// - Notifies the backend configurator of the new user ID and UUID via `backendConfigurator.login(...)`.
    func logoutUser() {
        let user = userManager.logout()
        let userId = user.userId
        let uuid = user.uuid
        backendConfigurator.login(userId: userId, userUUID: uuid)
    }

    // MARK: - Non-Async Entitlements
    
    /// Fetches entitlements associated with the currently logged-in user.
    ///
    /// - Parameter completionHandler: A closure that receives a `Result` containing:
    ///   - ``Entitlements`` on success, or
    ///   - ``RevenueMoreError`` on failure.
    ///
    /// **Usage**:
    /// ```swift
    /// RevenueMore.shared.getEntitlements { result in
    ///     switch result {
    ///     case .success(let entitlements):
    ///         // Handle success
    ///     case .failure(let error):
    ///         // Handle error
    ///     }
    /// }
    /// ```
    func getEntitlements(completionHandler: @escaping @Sendable (Result<Entitlements, RevenueMoreError>) -> Void) {
        self.entitlementManager.fetchEntitlements { result in
            switch result {
            case .success(let entitlements):
                completionHandler(.success(entitlements))
            case .failure(let error):
                completionHandler(.failure(error.convertPublicError))
            }
        }
    }

    // MARK: - Non-Async Transactions / Purchases

    /// Begins listening for payment transaction updates and reports them through a callback closure.
    ///
    /// - Parameter completion: A closure that receives a `Result` containing:
    ///   - ``RevenueMorePaymentTransaction`` on success, or
    ///   - ``RevenueMoreError`` on failure.
    ///
    /// **Behavior**:
    /// - The callback is called whenever a new or updated transaction is detected.
    /// - You can invoke `listenTransactions` multiple times if you want to handle
    ///   transactions in various parts of your app.
    func listenTransactions(completion: @escaping @Sendable (Result<RevenueMorePaymentTransaction, RevenueMoreError>) -> Void) {
        self.transactionManager.listenTransaction { result in
            switch result {
            case .success(let transaction):
                completion(.success(transaction))
            case .failure(let error):
                completion(.failure(error.convertPublicError))
            }
        }
    }

    /// Retrieves the current product offerings (or paywalls) for the user.
    ///
    /// - Parameter completionHandler: A closure called with a `Result` containing:
    ///   - ``Offerings`` on success, or
    ///   - ``RevenueMoreError`` on failure.
    func getOfferings(completionHandler: @escaping @Sendable (Result<Offerings, RevenueMoreError>) -> Void) {
        self.offeringManager.getOfferings { result in
            switch result {
            case .success(let offerings):
                completionHandler(.success(offerings))
            case .failure(let error):
                completionHandler(.failure(error.convertPublicError))
            }
        }
    }
    
    /// Initiates a non-async purchase of a ``RevenueMoreProduct``.
    ///
    /// - Parameters:
    ///   - product: The ``RevenueMoreProduct`` object representing the product to purchase.
    ///   - quantity: The number of items to purchase (defaults to 1).
    ///   - simulateAskToBuy: A Boolean indicating whether to simulate the Ask to Buy flow in sandbox.
    ///   - completion: A closure that receives a `Result` containing:
    ///     - ``RevenueMorePaymentTransaction`` on success,
    ///     - ``RevenueMoreError`` on failure.
    ///
    /// **Implementation Details**:
    /// - Calls `purchaseManager.purchase(...)`, passing along the product and other parameters.
    /// - Converts any internal errors to a public-facing error type before returning.
    func purchase(
        with product: RevenueMoreProduct,
        quantity: Int,
        simulateAskToBuy: Bool,
        completion: @escaping PublicPurchaseClosure
    ) {
        self.purchaseManager.purchase(
            with: product,
            quantity: quantity,
            simulateAskToBuy: simulateAskToBuy
        ) { result in
            switch result {
            case .success(let transaction):
                completion(.success(transaction))
            case .failure(let error):
                completion(.failure(error.convertPublicError))
            }
        }
    }

    /// Restores all previously purchased products for the current user (non-async version).
    ///
    /// - Parameter completion: A closure receiving a `Result` containing:
    ///   - An array of ``RevenueMorePaymentTransaction`` on success,
    ///   - ``RevenueMoreError`` on failure.
    func restore(completion: @escaping @Sendable (Result<[RevenueMorePaymentTransaction], RevenueMoreError>) -> Void) {
        self.purchaseManager.restore { result in
            switch result {
            case .success(let transactions):
                completion(.success(transactions))
            case .failure(let error):
                completion(.failure(error.convertPublicError))
            }
        }
    }

    // MARK: - Non-Async Manage Subscriptions
    
    /// Presents the "Manage Subscriptions" interface using StoreKit1 for platforms that do not support
    /// the async version or the StoreKit2 flow.
    ///
    /// - Parameter completion: A closure called with a boolean indicating whether the
    ///   subscription management interface was successfully shown (`true`) or not (`false`).
    ///
    /// - Note: This method is marked `@MainActor` because it must present a UI component on the main thread.
    @MainActor
    func showManageSubscriptionsNonAsync(completion: @escaping (Bool) -> Void) {
        storeKit1Manager.showManageSubscriptions(completion: completion)
    }

    // MARK: - Async Offerings

    /// Asynchronously fetches current product offerings.
    ///
    /// - Returns: An ``Offerings`` object describing the products available for purchase.
    /// - Throws: An error if the fetching process fails.
    /// - Note: Available on iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, or newer.
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    func offerings() async throws -> Offerings {
        return try await withCheckedThrowingContinuation { continuation in
            self.offeringManager.getOfferings { result in
                continuation.resume(with: result)
            }
        }
    }
    
    // MARK: - Async Purchases

    /// Asynchronously initiates a purchase for the specified product.
    ///
    /// - Parameters:
    ///   - product: The ``RevenueMoreProduct`` to purchase.
    ///   - simulateAskToBuy: Indicates if the Ask to Buy flow should be simulated in sandbox.
    ///   - quantity: The number of items to purchase (defaults to 1).
    /// - Returns: A ``RevenueMorePaymentTransaction`` object describing the outcome of the purchase.
    /// - Throws: An error if the purchase is unsuccessful.
    /// - Note: Available on iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, or newer.
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    func purchase(with product: RevenueMoreProduct, simulateAskToBuy: Bool, quantity: Int) async throws -> RevenueMorePaymentTransaction {
        return try await withCheckedThrowingContinuation { continuation in
            self.purchaseManager.purchase(with: product, quantity: quantity, simulateAskToBuy: simulateAskToBuy) { result in
                continuation.resume(with: result)
            }
        }
    }

    // MARK: - Async Manage Subscriptions

    /// Asynchronously shows the "Manage Subscriptions" UI using either StoreKit2 or StoreKit1 (fallback), depending on platform/OS version.
    ///
    /// - Throws: An error if the subscriptions interface cannot be presented.
    /// - Note:
    ///   - Available on iOS 13.0, macOS 10.15, tvOS 13.0 (and possibly xrOS).
    ///   - Unavailable on watchOS and tvOS under some constraints.
    ///   - Uses `@MainActor` to ensure UI presentation happens on the main thread.
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    @MainActor
    func showSubscriptionsAsync() async throws {
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, *), !ProcessInfo().isiOSAppOnMac {
            try await storeKit2Manager.showManageSubscriptions()
        } else {
            try await skShowManageSubscriptions()
        }
    }

    // MARK: - Async Entitlements

    /// Asynchronously fetches the current user's entitlements.
    ///
    /// - Returns: An ``Entitlements`` object representing the user’s active entitlements.
    /// - Throws: An error if fetching entitlements fails.
    /// - Note: Available on iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, or newer.
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    func getEntitlementsAsync() async throws -> Entitlements {
        return try await withCheckedThrowingContinuation { continuation in
            self.entitlementManager.fetchEntitlements { result in
                continuation.resume(with: result)
            }
        }
    }

    // MARK: - Async Transactions

    /// Asynchronously listens for incoming or updated payment transactions.
    ///
    /// - Returns: A ``RevenueMorePaymentTransaction`` describing a transaction whenever one is detected.
    /// - Throws: An error if listening for transactions fails.
    /// - Note: Available on iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, or newer.
    ///
    /// **Usage**:
    /// ```swift
    /// Task {
    ///     do {
    ///         let transaction = try await RevenueMore.shared.listenTransactions()
    ///         // Handle successful transaction
    ///     } catch {
    ///         // Handle error
    ///     }
    /// }
    /// ```
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    func listenTransactions() async throws -> RevenueMorePaymentTransaction {
        return try await withCheckedThrowingContinuation { continuation in
            self.transactionManager.listenTransaction { result in
                continuation.resume(with: result)
            }
        }
    }

    // MARK: - Async Restore

    /// Asynchronously restores previously purchased items for the current user.
    ///
    /// - Returns: An array of ``RevenueMorePaymentTransaction`` objects representing restored transactions.
    /// - Throws: An error if the restore process fails.
    /// - Note: Available on iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, or newer.
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    func restoreAsync() async throws -> [RevenueMorePaymentTransaction] {
        return try await withCheckedThrowingContinuation { continuation in
            purchaseManager.restore { result in
                continuation.resume(with: result)
            }
        }
    }
}

// MARK: - Private Extension (StoreKit1 Fallback)

private extension RevenueMore {
    
    /// Asynchronously attempts to show the Manage Subscriptions UI using StoreKit1.
    ///
    /// If the UI cannot be shown, throws a `.notShowManageSubscriptionsWithoutMessage` error.
    ///
    /// - Note: Only available on iOS 13.0, tvOS 13.0, macOS 10.15 or newer,
    ///   and marked `@MainActor` to ensure UI updates happen on the main thread.
    @available(iOS 13.0, tvOS 13.0, macOS 10.15, *)
    @available(watchOS, unavailable)
    @MainActor
    func skShowManageSubscriptions() async throws {
         try await withCheckedThrowingContinuation { continuation in
            self.storeKit1Manager.showManageSubscriptions { isShow in
                if isShow {
                    continuation.resume(returning: ())
                } else {
                    continuation.resume(throwing: RevenueMoreErrorInternal.notShowManageSubscriptionsWithoutMessage)
                }
            }
        }
    }
}
