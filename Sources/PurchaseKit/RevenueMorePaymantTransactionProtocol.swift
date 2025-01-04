// 
//  See LICENSE.text for this project’s licensing information.
//
//  RevenueMorePaymentTransactionProtocol.swift
//
//  Created by Bilal Durnagöl on 10.09.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// A protocol representing a payment transaction within the RevenueMore system.
///
/// Conforming types must supply transaction details such as identifiers,
/// product information, and transaction dates. They may optionally provide
/// a method to finish or complete the transaction asynchronously.
internal protocol RevenueMorePaymentTransactionProtocol: Sendable {
    
    /// A unique identifier for this transaction.
    ///
    /// For StoreKit 1 transactions, this matches `SKPaymentTransaction.transactionIdentifier`.
    /// For StoreKit 2 transactions, it could map to `Transaction.id` in some manner.
    var transactionIdentifier: String? { get }
    
    /// The identifier of the original transaction, if applicable.
    ///
    /// This is typically used to link subscription renewals to the initial purchase.
    /// For StoreKit 1, it corresponds to `SKPaymentTransaction.original?.transactionIdentifier`.
    var originalTransactionIdentifier: String? { get }
    
    /// The quantity of items purchased in this transaction.
    ///
    /// For StoreKit 1, this corresponds to `SKPayment.quantity`.
    /// For StoreKit 2, it would map to the `Transaction.quantity`.
    var quantity: Int { get }
    
    /// The identifier of the product being purchased.
    ///
    /// For StoreKit 1, this corresponds to `SKPayment.productIdentifier`.
    /// For StoreKit 2, it would map to `Transaction.productID`.
    var productId: String { get }
    
    /// The date on which the transaction occurred or was recorded.
    ///
    /// For StoreKit 1, it corresponds to `SKPaymentTransaction.transactionDate`.
    /// For StoreKit 2, it would map to `Transaction.purchaseDate`.
    var transactionDate: Date? { get }
    
    /// Finishes or completes the transaction asynchronously, if required by StoreKit.
    ///
    /// - Important: Only available on iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, and later.
    /// - Note: In StoreKit 1, you typically call `finishTransaction(_:)` on `SKPaymentQueue`.
    ///   In StoreKit 2, you might call `Transaction.finish()`.
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    func finish() async
}
