// 
//  See LICENSE.text for this project’s licensing information.
//
//  StoreKit1Purchase.swift
//
//  Created by Bilal Durnagöl on 15.04.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation
import StoreKit

/// A closure type used to handle a single payment transaction result.
///
/// - Parameters:
///   - queue: The `SKPaymentQueue` in which the transaction took place.
///   - result: A `Result` that contains either a successful `SKPaymentTransaction` or an `Error`.
typealias PaymentHandler = @Sendable (_ queue: SKPaymentQueue, _ result: Result<SKPaymentTransaction, Error>) -> Void

/// A closure type used to handle restore operations.
///
/// - Parameters:
///   - queue: The `SKPaymentQueue` where the restore operation occurred.
///   - error: An optional `Error` if the restore operation failed; otherwise `nil`.
typealias RestoreHandler = @Sendable (_ queue: SKPaymentQueue, _ error: Error?) -> Void

/// A closure type used to handle transaction updates in a high-level, app-defined format.
///
/// - Parameter result: A `Result` with `RM1PaymentTransaction` on success, or an `Error` on failure.
typealias TransactionHandler = @Sendable (Result<RM1PaymentTransaction, Error>) -> Void

/// A class responsible for managing StoreKit 1 purchases, transactions, and restore operations.
///
/// `StoreKit1Purchase` listens for payment transactions using `SKPaymentQueue`, handles purchases for
/// products, and provides a mechanism to restore completed transactions. It also allows optional
/// forced finishing of transactions, useful in certain test or sandbox scenarios.
///
/// **Thread-Safety**:
/// - This class is marked `@unchecked Sendable` and internally manages its own `DispatchQueue` (`dispatchQueue`)
///   for synchronizing payment handlers, restore handlers, and transaction callbacks.
internal class StoreKit1Purchase: NSObject, @unchecked Sendable {

    // MARK: - Properties

    /// An optional closure that can be set to listen to transaction updates in a high-level format.
    ///
    /// This handler is invoked with a `Result` containing either:
    /// - A successful `RM1PaymentTransaction`
    /// - Or an `Error` if the transaction process fails
    var onReceiveCompletionHandler: TransactionHandler?

    /// A queue used to synchronize operations, such as adding payment handlers or restore handlers.
    private let dispatchQueue: DispatchQueue

    /// A Boolean indicating whether transactions should be finished automatically once they're purchased or restored.
    private let forceFinishTransaction: Bool

    /// The `SKPaymentQueue` to which this object is added as an observer.
    private let paymentQueue: SKPaymentQueue

    /// An optional payment handler used as a fallback for product identifiers not found in `paymentHandlers`.
    private var fallbackHandler: PaymentHandler?

    /// A collection of closure handlers for restore operations. Each restore request appends a handler,
    /// which is later invoked when the restore operation completes or fails.
    private var restoreHandlers: [RestoreHandler] = []

    /// A dictionary mapping product identifiers (`String`) to an array of `PaymentHandler`s.
    ///
    /// When a product is purchased, the relevant array of handlers is invoked
    /// once the transaction for that product completes.
    private var paymentHandlers: [String: [PaymentHandler]] = [:]

    // MARK: - Initialization

    /// Initializes a new `StoreKit1Purchase` instance.
    ///
    /// - Parameters:
    ///   - queue: A `DispatchQueue` for synchronizing operations. Defaults to a queue named `Constants.Queue.PURCHASE_SK1`.
    ///   - forceFinishTransaction: A Boolean indicating whether to automatically finish transactions
    ///     once they're purchased or restored.
    ///   - paymentQueue: The `SKPaymentQueue` to be used. Defaults to `SKPaymentQueue.default()`.
    init(
        queue: DispatchQueue = DispatchQueue(label: Constants.Queue.PURCHASE_SK1),
        forceFinishTransaction: Bool,
        paymentQueue: SKPaymentQueue = SKPaymentQueue.default()
    ) {
        self.dispatchQueue = queue
        self.forceFinishTransaction = forceFinishTransaction
        self.paymentQueue = paymentQueue
    }

    // MARK: - Transaction Observation Lifecycle

    /// Begins observing the `SKPaymentQueue` for transaction updates.
    ///
    /// Adds `self` as an observer to `paymentQueue`, enabling the class to receive
    /// purchase, restore, and transaction change notifications.
    func startTransactionListener() {
        paymentQueue.add(self)
    }

    /// Stops observing the `SKPaymentQueue` for transaction updates.
    ///
    /// Removes `self` as an observer from `paymentQueue`, preventing further
    /// transaction update notifications from arriving.
    func stopTransactionListener() {
        paymentQueue.remove(self)
    }

    /// Sets a closure to be called whenever a transaction is updated.
    ///
    /// - Parameter completion: A closure that receives `Result<RM1PaymentTransaction, Error>` whenever a transaction is updated.
    ///
    /// **Usage**:
    /// ```swift
    /// storeKit1Purchase.listenPaymentTransactions { result in
    ///     switch result {
    ///     case .success(let transaction):
    ///         // Handle successful transaction
    ///     case .failure(let error):
    ///         // Handle error
    ///     }
    /// }
    /// ```
    func listenPaymentTransactions(completion: @escaping TransactionHandler) {
        onReceiveCompletionHandler = completion
    }

    // MARK: - Purchasing

    /// Initiates a purchase for the specified `SKProduct`.
    ///
    /// - Parameters:
    ///   - product: The `SKProduct` being purchased.
    ///   - uuid: A user or session identifier, embedded in the payment's `applicationUsername` property.
    ///   - quantity: The quantity of the product to purchase (must be >= 1).
    ///   - simulateAskToBuy: Whether to simulate the Ask to Buy flow in sandbox environments (if supported).
    ///   - completion: A closure that returns a `Result` containing:
    ///     - A successful `RM1PaymentTransaction`, or
    ///     - An `Error` if the purchase fails.
    ///
    /// **Behavior**:
    /// - Creates a payment using `SKMutablePayment(product:)`.
    /// - Registers a payment handler for the product identifier so the transaction can be handled.
    /// - Adds the payment to the `SKPaymentQueue`.
    func purchase(
        product: SKProduct,
        uuid: String,
        quantity: Int,
        simulateAskToBuy: Bool,
        completion: @escaping @Sendable (Result<RM1PaymentTransaction, Error>) -> Void
    ) {
        let payment = payment(
            product: product,
            appAccountToken: uuid,
            quantity: quantity,
            simulateAskToBuy: simulateAskToBuy
        )
        addPaymentHandler(with: payment.productIdentifier) { [weak self] _, result  in
            guard let self = self else { return }
            switch result {
            case .success(let transaction):
                self.handlePurchase(transaction: transaction, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
        paymentQueue.add(payment)
    }

    // MARK: - Restoring Purchases

    /// Restores all completed purchases for the current user.
    ///
    /// - Parameter completion: A closure that returns a `Result` containing:
    ///   - An array of `RM1PaymentTransaction` if successful,
    ///   - Or an `Error` if the restore process fails.
    ///
    /// **Behavior**:
    /// - Adds a restore handler to `restoreHandlers`.
    /// - Calls `SKPaymentQueue.restoreCompletedTransactions()`.
    func restorePayment(completion: @escaping @Sendable (Result<[RM1PaymentTransaction], Error>) -> Void) {
        dispatchQueue.async { [weak self] in
            guard let self = self else { return }
            self.addRestoreHandler { queue, error in
                self.handleRestore(queue: queue, error: error, completion: completion)
            }
            self.paymentQueue.restoreCompletedTransactions()
        }
    }

    // MARK: - Utility

    /// Checks if the user can make payments on the current device.
    ///
    /// - Returns: `true` if in-app purchases are allowed, otherwise `false`.
    ///
    /// **Example**:
    /// ```swift
    /// if StoreKit1Purchase.canMakePayments() {
    ///     // User can make payments
    /// } else {
    ///     // Show a message indicating payments are disabled
    /// }
    /// ```
    static func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }

    // MARK: - Private Methods

    /// Registers a new payment handler for the specified product identifier.
    ///
    /// - Parameters:
    ///   - productId: The product identifier string.
    ///   - handler: A `PaymentHandler` closure to handle the result of a transaction for `productId`.
    private func addPaymentHandler(with productId: String, handler: @escaping PaymentHandler) {
        dispatchQueue.async {
            var handlers: [PaymentHandler] = self.paymentHandlers[productId] ?? []
            handlers.append(handler)
            self.paymentHandlers[productId] = handlers
        }
    }

    /// Registers a new restore handler.
    ///
    /// - Parameter handler: A `RestoreHandler` closure to handle restore results.
    private func addRestoreHandler(handler: @escaping RestoreHandler) {
        dispatchQueue.async {
            self.restoreHandlers.append(handler)
        }
    }

    /// Handles the completion or failure of a restore operation.
    ///
    /// - Parameters:
    ///   - queue: The `SKPaymentQueue` where the restore occurred.
    ///   - error: An optional error if the restore failed.
    ///   - completion: A closure receiving a `Result` containing an array of `RM1PaymentTransaction` or an `Error`.
    private func handleRestore(
        queue: SKPaymentQueue,
        error: Error?,
        completion: @escaping (Result<[RM1PaymentTransaction], Error>) -> Void
    ) {
        if let error = error {
            completion(.failure(error))
            return
        }
        let transactions = queue.transactions
        completion(.success(transactions))
    }

    /// Handles the result of a single purchase transaction.
    ///
    /// - Parameters:
    ///   - transaction: The `SKPaymentTransaction` being handled.
    ///   - completion: A closure receiving a `Result` with an `RM1PaymentTransaction` or an `Error`.
    private func handlePurchase(
        transaction: SKPaymentTransaction,
        completion: @escaping (Result<RM1PaymentTransaction, Error>) -> Void
    ) {
        switch transaction.transactionState {
        case .purchasing:
            // Transaction is still in progress; do nothing.
            break
        case .purchased, .restored, .deferred:
            // .deferred indicates the transaction is awaiting parental approval or ask-to-buy.
            completion(.success(transaction))
        case .failed:
            if let error = transaction.error as? SKError {
                completion(.failure(error))
            }
        @unknown default:
            // Unrecognized transaction state (added in a future OS version).
            break
        }
    }
    
    /// Creates an `SKMutablePayment` object with the specified parameters.
    ///
    /// - Parameters:
    ///   - product: The `SKProduct` to be purchased.
    ///   - appAccountToken: A user or session UUID stored in the payment's `applicationUsername`.
    ///   - quantity: The number of items to purchase.
    ///   - simulateAskToBuy: If `true`, simulates the Ask to Buy flow in sandbox environments (macOS 10.14+).
    /// - Returns: A configured `SKMutablePayment` ready to be added to the payment queue.
    private func payment(product: RM1Product, appAccountToken: String, quantity: Int, simulateAskToBuy: Bool) -> SKMutablePayment {
        let payment = SKMutablePayment(product: product)
        payment.applicationUsername = appAccountToken
        payment.quantity = quantity
        if #available(macOS 10.14, *) {
            payment.simulatesAskToBuyInSandbox = simulateAskToBuy
        }
        return payment
    }
}

// MARK: - SKPaymentTransactionObserver

extension StoreKit1Purchase: SKPaymentTransactionObserver {

    /// Called by the payment queue when there are updates for one or more transactions.
    ///
    /// - Parameters:
    ///   - queue: The `SKPaymentQueue` containing the updated transactions.
    ///   - transactions: An array of `SKPaymentTransaction` objects that have been updated.
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            🍎(String(
                format: """
                \nproductId: %@\n state: %d\n transactionId: %@\n originalTransactionId: %@\n
                """,
                transaction.payment.productIdentifier,
                transaction.transactionState.rawValue,
                transaction.transactionIdentifier ?? "",
                transaction.original?.transactionIdentifier ?? ""
            ))
            switch transaction.transactionState {
            case .purchasing:
                🍎("Purchasing")
                continue
            case .deferred:
                🍎("Unknown transactionState: deferred")
            case .purchased, .restored:
                if self.forceFinishTransaction {
                    queue.finishTransaction(transaction)
                }
                onReceiveCompletionHandler?(.success(transaction))
            case .failed:
                queue.finishTransaction(transaction)
                if let error = transaction.error as? SKError {
                    onReceiveCompletionHandler?(.failure(error))
                }
            @unknown default:
                🍎("Unknown transactionState")
                continue
            }

            dispatchQueue.async {
                // Try to retrieve and remove matching handlers for this product ID.
                if let handlers = self.paymentHandlers.removeValue(forKey: transaction.payment.productIdentifier), !handlers.isEmpty {
                    DispatchQueue.main.async {
                        handlers.forEach { $0(queue, .success(transaction)) }
                    }
                } else {
                    // If no specific handler found, fall back to the fallback handler if set.
                    let handler = self.fallbackHandler
                    DispatchQueue.main.async {
                        handler?(queue, .success(transaction))
                    }
                }
            }
        }
    }

    /// Called by the payment queue when all restorable transactions have been processed.
    ///
    /// - Parameter queue: The `SKPaymentQueue` that finished the restore process.
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        dispatchQueue.async {
            let handlers = self.restoreHandlers
            self.restoreHandlers = []
            DispatchQueue.main.async {
                handlers.forEach { $0(queue, nil) }
            }
        }
    }

    /// Called by the payment queue when the restore process fails.
    ///
    /// - Parameters:
    ///   - queue: The `SKPaymentQueue` where the restore failed.
    ///   - error: An `Error` indicating why the restore operation failed.
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        dispatchQueue.async {
            let handlers = self.restoreHandlers
            self.restoreHandlers = []
            DispatchQueue.main.async {
                handlers.forEach { $0(queue, error) }
            }
        }
    }
}
