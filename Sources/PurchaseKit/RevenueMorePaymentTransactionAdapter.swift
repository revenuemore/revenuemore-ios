// 
//  See LICENSE.text for this project’s licensing information.
//
//  RevenueMorePaymentTransactionAdapter.swift
//
//  Created by Bilal Durnagöl on 10.09.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// An adapter class that implements `RevenueMorePaymentTransactionProtocol` for StoreKit 2 transactions.
///
/// `RevenueMorePaymentTransactionAdapter` wraps a `RM2PaymentTransaction`, providing
/// a unified interface that conforms to `RevenueMorePaymentTransactionProtocol`.
/// This allows compatibility with the rest of the RevenueMore system, regardless of
/// whether the underlying transaction came from StoreKit 1 or 2.
///
/// **Concurrency**:
/// - Marked `@unchecked Sendable` because it stores an `RM2PaymentTransaction` (a type that may have
///   its own concurrency considerations), but is designed to be used safely across concurrency domains
///   in combination with Swift's concurrency model.
@available(iOS 15.0, tvOS 15.0, macOS 12.0, *)
internal class RevenueMorePaymentTransactionAdapter: @unchecked Sendable, RevenueMorePaymentTransactionProtocol {

    // MARK: - Properties

    /// A StoreKit 2–based transaction.
    ///
    /// `RM2PaymentTransaction` is expected to wrap or represent a StoreKit 2 `Transaction`,
    /// providing fields such as `id`, `originalID`, and `finish()`.
    let transaction: RM2PaymentTransaction
    
    // MARK: - Initialization

    /// Initializes the adapter with a StoreKit 2 transaction.
    ///
    /// - Parameter transaction: The `RM2PaymentTransaction` to be adapted.
    init(transaction: RM2PaymentTransaction) {
        self.transaction = transaction
    }
    
    // MARK: - RevenueMorePaymentTransactionProtocol Conformance

    /// A unique identifier for this transaction, if available.
    ///
    /// Maps to `transaction.id`, converted to a string via `formatted()`.
    var transactionIdentifier: String? {
        return transaction.id.formatted()
    }
    
    /// The identifier of the original transaction, if applicable.
    ///
    /// Maps to `transaction.originalID`, also converted to a string via `formatted()`.
    /// Useful for subscription renewals or multi-phase purchases.
    var originalTransactionIdentifier: String? {
        return transaction.originalID.formatted()
    }

    /// The quantity of items purchased in this transaction.
    ///
    /// Corresponds to `transaction.purchasedQuantity`.
    var quantity: Int {
        return transaction.purchasedQuantity
    }
    
    /// Finishes or completes the transaction in StoreKit 2.
    ///
    /// Uses `await transaction.finish()`, which informs StoreKit that the app has
    /// successfully processed the transaction.
    func finish() async {
        await transaction.finish()
    }
    
    /// The product identifier for this transaction.
    ///
    /// Corresponds to `transaction.productID`.
    var productId: String {
        return transaction.productID
    }
    
    /// The date on which this transaction was recorded.
    ///
    /// Maps to `transaction.purchaseDate`, indicating when the user actually
    /// purchased the product or subscription.
    var transactionDate: Date? {
        return transaction.purchaseDate
    }
}
