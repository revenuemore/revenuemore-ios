// 
//  See LICENSE.text for this project’s licensing information.
//
//  TransactionManager.swift
//
//  Created by Bilal Durnagöl on 15.09.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// A manager class responsible for observing and handling StoreKit transaction updates.
///
/// `TransactionManager` can work with either a StoreKit1-based or StoreKit2-based manager,
/// determined by the system’s OS version. It provides methods to start, stop, and listen for
/// payment transactions, and then wraps these transactions in a ``RevenueMorePaymentTransaction``
/// before returning them via a completion handler.
///
/// **Concurrency**:
/// - Marked `@unchecked Sendable` because it holds a reference to a `storeKitManager`
///   (of type `any Sendable`), which must be safe to use across concurrency domains.
internal class TransactionManager: @unchecked Sendable {
    
    // MARK: - Properties
    
    /// A generic reference to either a `StoreKit1Manager` or `StoreKit2Manager` (or potentially other types).
    ///
    /// This is an `any Sendable` type to ensure it can be safely passed across concurrency boundaries.
    private let storeKitManager: (any Sendable)
    
    // MARK: - Initialization
    
    /// Initializes a new `TransactionManager` with the specified StoreKit manager.
    ///
    /// - Parameter storeKitManager: An object conforming to `Sendable`,
    ///   typically either a `StoreKit1Manager` or a `StoreKit2Manager`.
    init(storeKitManager: any Sendable) {
        self.storeKitManager = storeKitManager
    }
    
    // MARK: - Public Methods
    
    /// Begins listening for new or updated transactions, forwarding them to the provided completion closure.
    ///
    /// If the system meets iOS 15+ (or equivalent) requirements, this uses the StoreKit2 path.
    /// Otherwise, it falls back to StoreKit1.
    ///
    /// - Parameter completion: A closure returning a `Result` containing:
    ///   - A ``RevenueMorePaymentTransaction`` object on success, or
    ///   - A `RevenueMoreErrorInternal` on failure (e.g., StoreKit manager not initialized).
    func listenTransaction(completion: @escaping (TransactionClosure)) {
        if #available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *) {
            sk2ListenTransaction(completion: completion)
        } else {
            sk1ListenTransaction(completion: completion)
        }
    }
    
    /// Stops transaction listening if the underlying StoreKit manager is StoreKit1-based.
    ///
    /// Calls `stopListenPaymentTrasactions()` on `StoreKit1Manager`.
    /// If using StoreKit2, this method does nothing.
    func stopListenPaymentTrasactions() {
        guard
            let storeKit1Manager = storeKitManager as? StoreKit1Manager
        else {
            return
        }
        storeKit1Manager.stopListenPaymentTrasactions()
    }
    
    /// Starts transaction listening if the underlying StoreKit manager is StoreKit1-based.
    ///
    /// Calls `startTransactionListener()` on `StoreKit1Manager`.
    /// If using StoreKit2, this method does nothing.
    func startTransactionListener() {
        guard
            let storeKit1Manager = storeKitManager as? StoreKit1Manager
        else {
            return
        }
        storeKit1Manager.startTransactionListener()
    }
    
    // MARK: - Private Helper Methods
    
    /// Fallback for older systems (iOS <15, tvOS <15, watchOS <8, macOS <12), using StoreKit1 for transaction updates.
    ///
    /// - Parameter completion: A closure that receives a `Result` with a ``RevenueMorePaymentTransaction`` on success,
    ///   or a `RevenueMoreErrorInternal` on failure.
    private func sk1ListenTransaction(completion: @escaping (TransactionClosure)) {
        guard
            let storeKit1Manager = storeKitManager as? StoreKit1Manager
        else {
            completion(.failure(.notInitializedStoreKit1Manager))
            return
        }
        
        storeKit1Manager.listenPaymentTransactions { result in
            switch result {
            case .success(let transaction):
                let paymentTransaction = RevenueMorePaymentTransaction(transaction: transaction)
                completion(.success(paymentTransaction))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Uses StoreKit2 (iOS 15+, tvOS 15+, watchOS 8+, macOS 12+) to listen for transaction updates.
    ///
    /// - Parameter completion: A closure that returns updated or new transactions as
    ///   ``RevenueMorePaymentTransaction`` objects on success, or a `RevenueMoreErrorInternal` on failure.
    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    private func sk2ListenTransaction(completion: @escaping (TransactionClosure)) {
        guard
            let storeKit2Manager = storeKitManager as? StoreKit2Manager
        else {
            completion(.failure(.notInitializedStoreKit2Manager))
            return
        }
        
        storeKit2Manager.listenPaymentTransactions { transaction in
            let paymentTransaction = RevenueMorePaymentTransaction(transaction: transaction)
            completion(.success(paymentTransaction))
        }
    }
}
