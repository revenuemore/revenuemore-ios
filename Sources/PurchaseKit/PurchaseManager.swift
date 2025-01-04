// 
//  See LICENSE.text for this project’s licensing information.
//
//  PurchaseManager.swift
//
//  Created by Bilal Durnagöl on 10.09.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// A manager responsible for conducting purchases, restoring transactions, and completing payment flows.
///
/// `PurchaseManager` abstracts away StoreKit 1 and StoreKit 2 logic, choosing which
/// implementation to use based on the device’s OS version. It also manages receipts
/// and notifies subscription services once purchases are completed.
internal class PurchaseManager: @unchecked Sendable {
    
    // MARK: - Properties
    
    /// A generic reference to either a `StoreKit1Manager` or a `StoreKit2Manager`, depending on the OS version.
    private let storeKitManager: (any Sendable)
    
    /// A service used for subscription-related API calls (e.g., completing a payment on the backend).
    private var subscriptionsServices: SubscriptionServiceable
    
    /// A manager that handles retrieving and encoding the App Store receipt.
    private var receiptManager: ReceiptManager
    
    // MARK: - Initialization
    
    /// Initializes a new `PurchaseManager` with the necessary StoreKit manager, subscriptions service, and a receipt manager.
    ///
    /// - Parameters:
    ///   - storeKitManager: An object conforming to `Sendable`, generally a `StoreKit1Manager` or `StoreKit2Manager`.
    ///   - subscriptionsServices: A service conforming to `SubscriptionServiceable` to finalize subscription/purchase operations.
    ///   - receiptManager: A `ReceiptManager` responsible for generating and validating receipts.
    init(
        storeKitManager: any Sendable,
        subscriptionsServices: SubscriptionServiceable,
        receiptManager: ReceiptManager
    ) {
        self.storeKitManager = storeKitManager
        self.subscriptionsServices = subscriptionsServices
        self.receiptManager = receiptManager
    }
    
    // MARK: - Static Methods

    /// Checks if the current device and user environment allow making payments (i.e., in-app purchases).
    ///
    /// - Returns: `true` if in-app purchases are allowed; otherwise, `false`.
    /// - Note: If iOS 15 (or equivalent tvOS, watchOS, macOS) is available, calls `StoreKit2Manager.canMakePayments()`;
    ///   otherwise calls `StoreKit1Manager.canMakePayments()`.
    static func canMakePayments() -> Bool {
        if #available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *) {
           return StoreKit2Manager.canMakePayments()
        } else {
            return StoreKit1Manager.canMakePayments()
        }
    }
    
    // MARK: - Public Methods
    
    /// Initiates a purchase for a given product, with a specified quantity and optional Ask to Buy simulation.
    ///
    /// - Parameters:
    ///   - product: A ``RevenueMoreProduct`` describing the product to purchase.
    ///   - quantity: The number of items to purchase (must be >= 1).
    ///   - simulateAskToBuy: A Boolean indicating whether to simulate Ask to Buy in sandbox.
    ///   - completion: A closure that returns a `Result` containing either a ``RevenueMorePaymentTransaction`` on success,
    ///     or a `RevenueMoreErrorInternal` on failure.
    ///
    /// **Behavior**:
    /// - On iOS 15+, uses the StoreKit 2 flow via `sk2purhase`.
    /// - Otherwise, falls back to StoreKit 1 flow via `sk1purhase`.
    func purchase(
        with product: RevenueMoreProduct,
        quantity: Int,
        simulateAskToBuy: Bool,
        completion: @escaping (PurchaseClosure)
    ) {
        if #available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *) {
            sk2purhase(with: product, quantity: quantity, simulateAskToBuy: simulateAskToBuy, completion: completion)
        } else {
            sk1purhase(with: product, quantity: quantity, simulateAskToBuy: simulateAskToBuy, completion: completion)
        }
    }
    
    /// Restores any previously purchased products for the user.
    ///
    /// - Parameter completion: A closure that returns a `Result` containing an array of ``RevenueMorePaymentTransaction`` on success,
    ///   or a `RevenueMoreErrorInternal` on failure.
    ///
    /// **Behavior**:
    /// - On iOS 15+, uses the StoreKit 2 flow via `sk2Restore`.
    /// - Otherwise, falls back to StoreKit 1 flow via `sk1Restore`.
    func restore(completion: @escaping (RestoreClosure)) {
        if #available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *) {
            sk2Restore(completion: completion)
        } else {
            sk1Restore(completion: completion)
        }
    }
    
    // MARK: - Private Methods (StoreKit 2)
    
    /// Restores purchases using StoreKit 2.
    ///
    /// - Parameter completion: A closure that returns an array of ``RevenueMorePaymentTransaction`` on success,
    ///   or a `RevenueMoreErrorInternal` if something goes wrong.
    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    private func sk2Restore(completion: @escaping (RestoreClosure)) {
        guard
            let storeKit2Manager = storeKitManager as? StoreKit2Manager
        else {
            completion(.failure(.notInitializedStoreKit2Manager))
            return
        }
        
        Task {
            do {
                let result = try await storeKit2Manager.restorePayment()
                let revenueMorePaymentTransactions = result.map {
                    RevenueMorePaymentTransaction(transaction: $0)
                }
                self.paymentComplete { paymentResult in
                    switch paymentResult {
                    case .success:
                        completion(.success(revenueMorePaymentTransactions))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            } catch let error as RevenueMoreErrorInternal {
                completion(.failure(error))
            }
        }
    }
    
    /// Performs a purchase with StoreKit 2 for a given ``RevenueMoreProduct``.
    ///
    /// - Parameters:
    ///   - product: The ``RevenueMoreProduct`` to purchase, expected to have a `.sk2Product` available.
    ///   - quantity: The number of units to purchase.
    ///   - simulateAskToBuy: Whether to simulate the Ask to Buy flow in sandbox.
    ///   - completion: A `PurchaseClosure` that delivers the result of the purchase.
    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    private func sk2purhase(
        with product: RevenueMoreProduct,
        quantity: Int,
        simulateAskToBuy: Bool,
        completion: @escaping (PurchaseClosure)
    ) {
        guard
            let storeKit2Manager = storeKitManager as? StoreKit2Manager
        else {
            completion(.failure(.notInitializedStoreKit1Manager))
            return
        }
        
        guard let sk2Product = product.sk2Product else {
            completion(.failure(.notFoundProduct))
            return
        }
        
        Task {
            do {
                let transaction = try await storeKit2Manager.purchase(
                    product: sk2Product,
                    simulateAskToBuy: simulateAskToBuy,
                    quantity: quantity
                )
                let revenueMorePaymentTransaction = RevenueMorePaymentTransaction(transaction: transaction)
                self.paymentComplete { paymentResult in
                    switch paymentResult {
                    case .success:
                        completion(.success(revenueMorePaymentTransaction))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            } catch let error as RevenueMoreErrorInternal {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private Methods (StoreKit 1)
    
    /// Restores purchases using StoreKit 1.
    ///
    /// - Parameter completion: A closure that returns an array of ``RevenueMorePaymentTransaction`` on success,
    ///   or a `RevenueMoreErrorInternal` if something goes wrong.
    private func sk1Restore(completion: @escaping (RestoreClosure)) {
        guard
            let storeKit1Manager = storeKitManager as? StoreKit1Manager
        else {
            completion(.failure(.notInitializedStoreKit1Manager))
            return
        }
        
        storeKit1Manager.restorePayment { [weak self] result in
            switch result {
            case .success(let transactions):
                let revenueMorePaymentTransactions = transactions.map {
                    RevenueMorePaymentTransaction(transaction: $0)
                }
                self?.paymentComplete { paymentResult in
                    switch paymentResult {
                    case .success:
                        completion(.success(revenueMorePaymentTransactions))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Performs a purchase with StoreKit 1 for a given ``RevenueMoreProduct``.
    ///
    /// - Parameters:
    ///   - product: The ``RevenueMoreProduct`` to purchase, expected to have a `.sk1Product`.
    ///   - quantity: The number of units to purchase.
    ///   - simulateAskToBuy: Whether to simulate the Ask to Buy flow in sandbox.
    ///   - completion: A closure that returns a ``RevenueMorePaymentTransaction`` on success,
    ///     or `RevenueMoreErrorInternal` on failure.
    private func sk1purhase(
        with product: RevenueMoreProduct,
        quantity: Int,
        simulateAskToBuy: Bool,
        completion: @escaping (PurchaseClosure)
    ) {
        guard
            let storeKit1Manager = storeKitManager as? StoreKit1Manager
        else {
            completion(.failure(.notInitializedStoreKit1Manager))
            return
        }
        
        guard let sk1Product = product.sk1Product else {
            completion(.failure(.notFoundProduct))
            return
        }
        
        storeKit1Manager.purchase(
            with: sk1Product,
            quantity: quantity,
            simulateAskToBuy: simulateAskToBuy
        ) { [weak self] result in
            switch result {
            case .success(let transaction):
                let revenueMorePaymentTransaction = RevenueMorePaymentTransaction(transaction: transaction)
                self?.paymentComplete { paymentResult in
                    switch paymentResult {
                    case .success:
                        completion(.success(revenueMorePaymentTransaction))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Common Purchase Completion

    /// Completes the purchase flow by generating a receipt and notifying the subscription service.
    ///
    /// - Parameter completion: A closure returning a `Result<Void, RevenueMoreErrorInternal>` indicating
    ///   if the receipt validation and subscription update succeeded.
    private func paymentComplete(completion: @escaping @Sendable (Result<Void, RevenueMoreErrorInternal>) -> Void) {
        receiptManager.generateReceiptString { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let receipt):
                let request = PaymentComplete.Request(receiptData: receipt)
                self.subscriptionsServices.complete(request: request) { result in
                    switch result {
                    case .success:
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(.paymentCompletedWithFailure(error.customMessage)))
                    }
                }
            case .failure(let error):
                completion(.failure(.paymentCompletedWithFailure(error.description)))
            }
        }
    }
}
