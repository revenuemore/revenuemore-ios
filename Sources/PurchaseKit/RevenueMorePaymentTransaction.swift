// 
//  See LICENSE.text for this project’s licensing information.
//
//  RevenueMorePaymentTransaction.swift
//
//  Created by Bilal Durnagöl on 10.09.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import StoreKit

/// A type that adapts StoreKit 1 or StoreKit 2 transactions to a unified payment transaction protocol.
///
/// ``RevenueMorePaymentTransaction`` conforms to `RevenueMorePaymentTransactionProtocol` and can represent either
/// a StoreKit 1 transaction (`RM1PaymentTransaction`) or a StoreKit 2 transaction (`RM2PaymentTransaction`),
/// depending on the iOS version or runtime environment. Internally, it delegates to either
/// `SKRevenueMorePaymentTransactionAdapter` (StoreKit 1) or `RevenueMorePaymentTransactionAdapter` (StoreKit 2).
///
/// **Concurrency**:
/// - Marked `@unchecked Sendable` because it can wrap different StoreKit transaction types,
///   some of which may have concurrency or thread-safety considerations.
public struct RevenueMorePaymentTransaction: @unchecked Sendable, RevenueMorePaymentTransactionProtocol {
    
    // MARK: - Private Properties
    
    /// An internal adapter that actually implements the `RevenueMorePaymentTransactionProtocol` requirements.
    ///
    /// Depending on the initializer used, this adapter will be:
    /// - `SKRevenueMorePaymentTransactionAdapter` if wrapping a StoreKit 1 transaction (`RM1PaymentTransaction`).
    /// - `RevenueMorePaymentTransactionAdapter` if wrapping a StoreKit 2 transaction (`RM2PaymentTransaction`).
    private let adapter: RevenueMorePaymentTransactionProtocol
    
    // MARK: - Initialization
    
    /// Initializes a new ``RevenueMorePaymentTransaction`` by wrapping a StoreKit 2 transaction (`RM2PaymentTransaction`).
    ///
    /// - Parameter transaction: A StoreKit 2 transaction object to adapt.
    /// - Requires: iOS 15.0 (or equivalent tvOS, watchOS, macOS versions) or newer for StoreKit 2.
    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    init(transaction: RM2PaymentTransaction) {
        self.adapter = RevenueMorePaymentTransactionAdapter(transaction: transaction)
    }

    /// Initializes a new ``RevenueMorePaymentTransaction`` by wrapping a StoreKit 1 transaction (`RM1PaymentTransaction`).
    ///
    /// - Parameter transaction: A StoreKit 1 transaction object to adapt.
    init(transaction: RM1PaymentTransaction) {
        self.adapter = SKRevenueMorePaymentTransactionAdapter(transaction: transaction)
    }
    
    // MARK: - RevenueMorePaymentTransactionProtocol Conformance

    /// A unique identifier for the transaction, as provided by StoreKit.
    ///
    /// In StoreKit 1, corresponds to `SKPaymentTransaction.transactionIdentifier`.
    /// In StoreKit 2, corresponds to `Transaction.id`.
    public var transactionIdentifier: String? {
        return adapter.transactionIdentifier
    }
    
    /// The identifier of the original transaction, if available (e.g., for subscription renewals).
    ///
    /// In StoreKit 1, corresponds to `SKPaymentTransaction.original?.transactionIdentifier`.
    /// In StoreKit 2, might map to `Transaction.originalID` or similar logic.
    public var originalTransactionIdentifier: String? {
        return adapter.originalTransactionIdentifier
    }
 
    /// The quantity of items purchased in this transaction.
    ///
    /// In StoreKit 1, corresponds to `SKPayment.quantity`.
    /// In StoreKit 2, might come from `Transaction.quantity`.
    public var quantity: Int {
        return adapter.quantity
    }
    
    /// Finishes or completes the transaction, if required by StoreKit.
    ///
    /// - Important: Only available on iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, or newer.
    /// - Note: In StoreKit 1, you typically call `SKPaymentQueue.finishTransaction(_:)`.
    ///   In StoreKit 2, you call `Transaction.finish()`.
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    public func finish() async {
        await adapter.finish()
    }
    
    /// The product identifier for the purchased product.
    ///
    /// In StoreKit 1, corresponds to `SKPayment.productIdentifier`.
    /// In StoreKit 2, corresponds to `Transaction.productID`.
    public var productId: String {
        return adapter.productId
    }
    
    /// The date on which the transaction was recorded, if available.
    ///
    /// In StoreKit 1, corresponds to `SKPaymentTransaction.transactionDate`.
    /// In StoreKit 2, corresponds to `Transaction.purchaseDate`.
    public var transactionDate: Date? {
        return adapter.transactionDate
    }
    
    // MARK: - StoreKit 1 & StoreKit 2 Accessors

    /// Provides access to the underlying StoreKit 1 transaction if this object was created from one,
    /// or `nil` otherwise.
    ///
    /// If the adapter is an `SKRevenueMorePaymentTransactionAdapter`, this property exposes
    /// its `transaction` as an `RM1PaymentTransactionPublic`.
    public var sk1PaymentTransaction: RM1PaymentTransactionPublic? {
        return (self.adapter as? SKRevenueMorePaymentTransactionAdapter)?.transaction
    }

    /// Provides access to the underlying StoreKit 2 transaction if this object was created from one,
    /// or `nil` otherwise.
    ///
    /// If the adapter is a `RevenueMorePaymentTransactionAdapter`, this property exposes
    /// its `transaction` as an `RM2PaymentTransactionPublic`.
    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    public var sk2PaymentTransaction: RM2PaymentTransactionPublic? {
        return (self.adapter as? RevenueMorePaymentTransactionAdapter)?.transaction
    }
}
