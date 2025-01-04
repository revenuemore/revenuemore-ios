// 
//  See LICENSE.text for this project’s licensing information.
//
//  StoreKit2Purchase.swift
//
//  Created by Bilal Durnagöl on 30.06.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation
import StoreKit

/// A typealias for a closure that handles payment transaction updates asynchronously.
///
/// This typealias defines a closure that takes a `Transaction` object as its parameter and performs
/// asynchronous operations. It is used to handle updates to payment transactions, allowing for
/// asynchronous processing of transaction details such as verifying receipts, updating the UI, or
/// performing other necessary actions.
///
/// - Parameter transaction: The `Transaction` object representing the payment transaction to be handled.
///
/// - Note: This typealias requires iOS 15.0, tvOS 15.0, watchOS 8.0, or macOS 12.0 and later.
@available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
public typealias TransactionUpdate = ((Transaction) async -> Void)

@available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
internal class StoreKit2Purchase: ObservableObject, @unchecked Sendable {
    // MARK: - PROPERTIES

    /// A task that handles asynchronous operations for payment transactions.
    ///
    /// This private variable is used to manage the lifecycle of asynchronous tasks related to payment
    /// transactions. It can be used to start, cancel, or await the completion of these tasks.
    private var task: Task<Void, Never>!

    /// A boolean flag indicating whether to forcefully finish a transaction.
    ///
    /// This constant determines whether transactions should be automatically finished after being processed.
    /// When set to `true`, transactions are finished without requiring additional steps from the developer.
    private let forceFinishTransaction: Bool

    /// A closure that handles payment transaction updates asynchronously.
    ///
    /// This optional property holds a `TransactionUpdate` closure, which is called when there are updates
    /// to payment transactions. The closure is executed asynchronously, allowing for the processing of
    /// transaction details such as verifying receipts, updating the UI, or performing other necessary actions.
    ///
    /// - SeeAlso:
    ///   - ``TransactionUpdate``: The typealias for the closure handling transaction updates.
    private var onReceiveCompletionHandler: TransactionUpdate?

    // MARK: - INIT(s)

    init(forceFinishTransaction: Bool) {

        self.forceFinishTransaction = forceFinishTransaction

        task = Task.detached { [unowned self] in
            for await result in Transaction.updates {
                _ = try? await processTransaction(result: result)
            }
        }
    }

    deinit {
        task.cancel()
    }

    /// Initiates the purchase of a product with the given parameters.
    ///
    /// This asynchronous function attempts to purchase a specified product using provided options such as
    /// app account token, quantity, and simulation of "Ask to Buy". It handles different purchase outcomes,
    /// including success (verified and unverified transactions), pending transactions, user cancellations,
    /// and unknown errors.
    ///
    /// - Parameters:
    ///   - product: The `RM2Product` to be purchased.
    ///   - uuid: A unique identifier for the app account token.
    ///   - simulateAskToBuy: A boolean indicating whether to simulate "Ask to Buy" (default is `false`).
    ///   - quantity: The quantity of the product to be purchased (default is `1`).
    ///
    /// - Returns: An `RM2Purchase` object representing the successful purchase.
    ///
    /// - Throws: ``RevenueMoreError`` in case of various purchase failures, including pending transactions,
    ///   user cancellations, and other errors.
    ///
    /// - Note: Ensure that the product and related configurations are properly set up before calling this method.
    ///   This function uses Swift's async/await pattern and requires iOS 15.0+.
    ///
    /// ```swift
    /// do {
    ///     let purchase = try await buy(product: product, uuid: "unique-uuid", simulateAskToBuy: false, quantity: 1)
    ///     // Handle successful purchase
    /// } catch RevenueMoreError.purchaseIsPending {
    ///     // Handle pending purchase
    /// } catch RevenueMoreError.purchaseCanceledByUser {
    ///     // Handle user cancellation
    /// } catch {
    ///     // Handle other errors
    /// }
    /// ```
    ///
    /// - SeeAlso:
    ///   - ``RM2Product``: The type representing the product to be purchased.
    ///   - ``RM2Purchase``: The type representing the purchase result.
    ///   - ``RevenueMoreError``: The type representing potential errors during the purchase process.
    func purchase(product: RM2Product, uuid: String, simulateAskToBuy: Bool = false, quantity: Int = 1) async throws -> RM2PaymentTransaction {
        let optionals = payment(appAccountToken: uuid, quantity: quantity, simulateAskToBuy: simulateAskToBuy)
        do {
            #if os(xrOS)
            guard let windowsScene = await UIApplication.shared.windowsScene else {
                throw RevenueMoreErrorInternal.notFoundWindowScene
            }
            let result = try await product.purchase(confirmIn: windowsScene, options: optionals)
            #else
            let result = try await product.purchase(options: optionals)
            #endif
            switch result {
            case let .success(.verified(transaction)):
                // Successful purhcase
                if forceFinishTransaction {
                    await transaction.finish()
                }

                return transaction
            case let .success(.unverified(transaction, error)):
                🗣("Successful purchase but transaction/receipt can't be verified. Error: \(error)")
                🗣("Could be a jailbroken phone")
                return transaction
            case .pending:
                🗣("Transaction waiting on SCA (Strong Customer Authentication) or approval from Ask to Buy")
                throw RevenueMoreErrorInternal.purchaseIsPending
            case .userCancelled:
                🗣("User Cancelled!")
                throw RevenueMoreErrorInternal.purchaseCanceledByUser
            @unknown default:
                🗣("Failed to purchase the product!")
                throw RevenueMoreErrorInternal.purhaseFailedWithoutMessage
            }
        } catch {
            throw RevenueMoreErrorInternal.purhaseFailed(error.localizedDescription)
        }
    }

    /// Restores previously completed in-app purchases.
    ///
    /// This asynchronous function attempts to restore previously completed in-app purchases by
    /// synchronizing with the App Store. If an error occurs during the restoration process, it throws
    /// a ``RevenueMoreError`` with a detailed message.
    ///
    /// - Throws: ``RevenueMoreError`` if an error occurs during the restoration process.
    ///
    /// ```swift
    /// do {
    ///     try await restorePayment()
    ///     // Handle successful restoration
    /// } catch {
    ///     // Handle restoration error
    /// }
    /// ```
    ///
    /// - SeeAlso:
    ///   - `AppStore.sync()`: The method used to synchronize with the App Store to restore purchases.
    ///   - ``RevenueMoreError``: The type representing potential errors during the restoration process.
    func restorePayment() async throws -> [RM2PaymentTransaction] {
        do {
            try await AppStore.sync()
            var transactions: [Transaction] = []
            for await result in Transaction.currentEntitlements {
                if case let .verified(transaction) = result {
                    transactions.append(transaction)
                }
            }
            return transactions
        } catch let error {
            throw RevenueMoreErrorInternal.restorePaymentFailed(error.localizedDescription)
        }
    }

    /// Sets a completion handler to listen for payment transaction updates.
    ///
    /// This function assigns the provided closure to the `onReceiveCompletionHandler` property.
    /// The closure will be called whenever there are updates to payment transactions, allowing the
    /// caller to handle the transaction results, such as updating the UI or processing the transaction details.
    ///
    /// - Parameter completion: A closure of type `TransactionUpdate` that will be called when payment
    ///   transactions are updated. This closure is executed asynchronously and handles the transaction updates.
    ///
    /// - Note: Ensure that the `onReceiveCompletionHandler` property is properly defined to hold the
    ///   closure. This function is used to set up the transaction handling logic in a convenient way.
    func listenPaymentTransactions(completion: @escaping TransactionUpdate) {
        onReceiveCompletionHandler = completion
    }
    
    /// Contains properties and methods to facilitate interactions between your app and the App Store.
    static func canMakePayments() -> Bool {
        return AppStore.canMakePayments
    }

    /// Creates a set of purchase options for a product transaction.
    ///
    /// This private function constructs a set of purchase options to be used when initiating a product
    /// purchase. The options include the quantity of the product, whether to simulate "Ask to Buy" in
    /// the sandbox environment, and an optional app account token.
    ///
    /// - Parameters:
    ///   - appAccountToken: A string representing the app account token. This token is converted to a `UUID`
    ///     and included in the purchase options if valid.
    ///   - quantity: The quantity of the product to be purchased.
    ///   - simulateAskToBuy: A boolean indicating whether to simulate "Ask to Buy" in the sandbox environment.
    ///
    /// - Returns: A set of `Product.PurchaseOption` values representing the purchase options.
    ///
    /// ```swift
    /// let purchaseOptions = payment(appAccountToken: "unique-uuid", quantity: 2, simulateAskToBuy: true)
    /// // Use `purchaseOptions` to initiate a product purchase
    /// ```
    ///
    /// - SeeAlso:
    ///   - `Product.PurchaseOption`: An enumeration representing the different purchase options available.
    private func payment(appAccountToken: String, quantity: Int, simulateAskToBuy: Bool) -> Set<Product.PurchaseOption> {
        var options: Set<Product.PurchaseOption> = []
        options.insert(.quantity(quantity))
        options.insert(.simulatesAskToBuyInSandbox(simulateAskToBuy))
        if let appAccountToken = UUID(uuidString: appAccountToken) {
            options.insert(.appAccountToken(appAccountToken))
        }
        return options
    }

    /// Processes a payment transaction and handles its verification result.
    ///
    /// This private asynchronous function processes the result of a transaction verification. It extracts
    /// the transaction from the result, calls the `onReceiveCompletionHandler` if set, and optionally finishes
    /// the transaction if `forceFinishTransaction` is true. Depending on whether the transaction is verified
    /// or unverified, it either returns the verified transaction or throws an error.
    ///
    /// - Parameter result: The `VerificationResult<Transaction>` representing the outcome of a transaction verification.
    ///
    /// - Returns: The verified `Transaction` if the verification is successful.
    ///
    /// - Throws: `RevenueMoreError.transactionListener` if the transaction is unverified.
    ///
    /// ```swift
    /// do {
    ///     let transaction = try await processTransaction(result: verificationResult)
    ///     // Handle the verified transaction
    /// } catch {
    ///     // Handle the error for an unverified transaction
    /// }
    /// ```
    ///
    /// - SeeAlso:
    ///   - `Transaction`: The type representing a payment transaction.
    ///   - `VerificationResult`: The type representing the result of a transaction verification.
    ///   - ``RevenueMoreError``: The type representing potential errors during transaction processing.
    private func processTransaction(result: VerificationResult<Transaction>) async throws -> Transaction {
        let transaction = try result.payloadValue

        Task { await onReceiveCompletionHandler?(transaction) }
        if forceFinishTransaction {
            Task { await transaction.finish() }
        }
        switch result {
        case .verified(let safe):
            return safe
        case .unverified:
            throw RevenueMoreErrorInternal.transactionListenerUnverified
        }
    }
}
