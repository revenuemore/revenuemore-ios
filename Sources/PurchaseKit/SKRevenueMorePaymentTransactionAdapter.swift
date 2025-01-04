// 
//  See LICENSE.text for this project’s licensing information.
//
//  SKRevenueMorePaymentTransactionAdapter.swift
//
//  Created by Bilal Durnagöl on 10.09.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// An adapter class that implements `RevenueMorePaymentTransactionProtocol` for StoreKit 1 transactions.
///
/// `SKRevenueMorePaymentTransactionAdapter` wraps an `RM1PaymentTransaction`, providing
/// a unified interface that aligns with the `RevenueMorePaymentTransactionProtocol`.
/// This allows for consistent handling of transactions whether they originate from
/// StoreKit 1 or StoreKit 2 environments.
///
/// **Concurrency**:
/// - Marked `@unchecked Sendable` because it holds an `RM1PaymentTransaction` reference.
///   Though this should be safe across concurrency boundaries, ensure that `RM1PaymentTransaction`
///   itself is accessed in a thread-safe manner.
internal class SKRevenueMorePaymentTransactionAdapter: @unchecked Sendable, RevenueMorePaymentTransactionProtocol {

    /// The underlying StoreKit 1 transaction.
    ///
    /// `RM1PaymentTransaction` is expected to wrap or represent a `SKPaymentTransaction` from StoreKit 1,
    /// containing details such as `transactionIdentifier`, `original`, and `transactionDate`.
    let transaction: RM1PaymentTransaction
    
    // MARK: - Initialization

    /// Initializes the adapter with a StoreKit 1 transaction.
    ///
    /// - Parameter transaction: The `RM1PaymentTransaction` to be adapted.
    init(transaction: RM1PaymentTransaction) {
        self.transaction = transaction
    }

    // MARK: - RevenueMorePaymentTransactionProtocol Conformance

    /// A unique identifier for this transaction, if available.
    ///
    /// Corresponds to `transaction.transactionIdentifier` in StoreKit 1.
    var transactionIdentifier: String? {
        return transaction.transactionIdentifier
    }
    
    /// The identifier of the original transaction, if applicable (e.g., for subscription renewals).
    ///
    /// Corresponds to `transaction.original?.transactionIdentifier` in StoreKit 1.
    var originalTransactionIdentifier: String? {
        return transaction.original?.transactionIdentifier
    }

    /// The quantity of items purchased in this transaction.
    ///
    /// Obtained from `transaction.payment.quantity` in StoreKit 1.
    var quantity: Int {
        return transaction.payment.quantity
    }
    
    /// The product identifier for this transaction.
    ///
    /// Obtained from `transaction.payment.productIdentifier` in StoreKit 1.
    var productId: String {
        return transaction.payment.productIdentifier
    }
    
    /// The date on which the transaction was recorded, if available.
    ///
    /// Corresponds to `transaction.transactionDate` in StoreKit 1.
    var transactionDate: Date? {
        return transaction.transactionDate
    }
    
    /// Finishes or completes the transaction (StoreKit 1 flow).
    ///
    /// - Important: Only available on iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, or later.
    /// - Note: In a StoreKit 1 context, you typically call `finishTransaction(_:)` on `SKPaymentQueue`.
    ///   Here, no direct call is needed, but the method is provided to satisfy the protocol requirement
    ///   and maintain parity with StoreKit 2–based finishes.
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    func finish() async {
        // Placeholder: Typically, `SKPaymentQueue.finishTransaction(transaction)` is invoked externally.
    }
}
