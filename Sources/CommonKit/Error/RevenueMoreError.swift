// 
//  See LICENSE.text for this project’s licensing information.
//
//  RevenueMoreError.swift
//
//  Created by Bilal Durnagöl on 26.05.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// A type alias for `NSError` used to represent errors within the RevenueMore module.
public typealias RevenueMoreError = NSError

// MARK: - Internal RevenueMore Errors

/// An internal enumeration of errors that can occur in the RevenueMore module.
///
/// Each case includes an error-specific code, message, or additional context.
/// The `RevenueMoreErrorInternal` conforms to:
/// - `Error` for throwing and catching errors
/// - `Equatable` for equality checks
/// - `LocalizedError` for user-friendly messages
/// - `CustomStringConvertible` for string descriptions
/// - `CustomNSError` for bridging to `NSError`
internal enum RevenueMoreErrorInternal: Error, Equatable {
    
    /// An unexpected error.
    case unexpected
    
    /// Indicates that an offering was not found.
    case notFoundOffering
    
    /// Indicates that a product was not found.
    case notFoundProduct
    
    /// An error that occurs when fetching paywalls.
    ///
    /// - Parameter message: A string describing the specific issue encountered while fetching paywalls.
    case fetchPaywalls(_ message: String)
    
    /// StoreKit1 manager was not initialized before use.
    case notInitializedStoreKit1Manager
    
    /// StoreKit2 manager was not initialized before use.
    case notInitializedStoreKit2Manager
    
    /// A store product was not found in the system.
    case notFoundStoreProduct
    
    /// A set of product identifiers was not found.
    case notFoundProductIDs
    
    /// An error that occurs when fetching products.
    ///
    /// - Parameter message: A message describing the specific issue encountered.
    case fetchProductFailed(_ message: String)
    
    /// A window scene was not found (i.e., iOS scene-based UI context is missing).
    case notFoundWindowScene
    
    /// An error that occurs when manage subscriptions view cannot be shown.
    ///
    /// - Parameter message: A message describing why the subscriptions view cannot be shown.
    case notShowManageSubscriptions(_ message: String?)
    
    /// An error that occurs when manage subscriptions view cannot be shown, without a specific message.
    case notShowManageSubscriptionsWithoutMessage
    
    /// An error that occurs when restoring a payment fails.
    ///
    /// - Parameter message: A message describing the reason for the failure.
    case restorePaymentFailed(_ message: String)
    
    /// An error that occurs when listening for a payment fails.
    ///
    /// - Parameter message: A message describing the reason for the failure.
    case listenPaymentFailed(_ message: String)
    
    /// An error that occurs when a purchase fails.
    ///
    /// - Parameter message: A message describing the reason for the failure.
    case purhaseFailed(_ message: String)
    
    /// Indicates that a purchase was canceled by the user.
    case purchaseCanceledByUser
    
    /// Indicates that a purchase is pending.
    case purchaseIsPending
    
    /// An error for a failed purchase with no specific message.
    case purhaseFailedWithoutMessage
    
    /// Indicates that a transaction listener has found a transaction to be unverified.
    case transactionListenerUnverified
    
    /// An error that occurs when the payment completes with a failure.
    ///
    /// - Parameter message: A message describing the failure event.
    case paymentCompletedWithFailure(_ message: String)
    
    /// An error that occurs when fetching entitlements.
    ///
    /// - Parameter message: A message describing the specific issue during entitlement fetch.
    case fetchEntitlements(_ message: String)
    
    /// Indicates that the user’s receipt is invalid.
    case invalidReceipt
    
    /// Indicates that a URL is invalid or malformed.
    case badURL
    
    // MARK: - Conversion to Public Error
    
    /// Converts the internal error to a ``RevenueMoreError`` (`NSError`).
    ///
    /// This is useful for bridging Swift errors into Objective-C APIs.
    var convertPublicError: RevenueMoreError {
        return NSError(
            domain: Self.errorDomain,
            code: self.errorCode,
            userInfo: self.errorUserInfo
        )
    }
}

extension RevenueMoreErrorInternal: LocalizedError {
    
    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        switch self {
        case .unexpected:
            return Localizations.RevenueMoreError.Description.unexpected
        case .notFoundOffering:
            return Localizations.RevenueMoreError.Description.notFoundOffering
        case .notFoundProduct:
            return Localizations.RevenueMoreError.Description.notFoundProduct
        case .fetchPaywalls(let message):
            return message
        case .notInitializedStoreKit1Manager:
            return Localizations.RevenueMoreError.Description.notInitializedStoreKit1Manager
        case .notFoundStoreProduct:
            return Localizations.RevenueMoreError.Description.notFoundStoreProduct
        case .notFoundProductIDs:
            return Localizations.RevenueMoreError.Description.notFoundProductIds
        case .notInitializedStoreKit2Manager:
            return Localizations.RevenueMoreError.Description.notInitializedStoreKit2Manager
        case .fetchProductFailed(let message):
            return message
        case .notFoundWindowScene:
            return Localizations.RevenueMoreError.Description.notFoundWindowScene
        case .notShowManageSubscriptions(let message):
            return message
        case .restorePaymentFailed(let message):
            return message
        case .listenPaymentFailed(let message):
            return message
        case .purhaseFailed(let message):
            return message
        case .purchaseCanceledByUser:
            return Localizations.RevenueMoreError.Description.purchaseCanceledByUser
        case .purchaseIsPending:
            return Localizations.RevenueMoreError.Description.purchaseIsPending
        case .purhaseFailedWithoutMessage:
            return Localizations.RevenueMoreError.Description.purhaseFailedWitoutMessage
        case .transactionListenerUnverified:
            return Localizations.RevenueMoreError.Description.transactionListenerUnverified
        case .paymentCompletedWithFailure(let message):
            return message
        case .notShowManageSubscriptionsWithoutMessage:
            return Localizations.RevenueMoreError.Description.notShowManageSubscriptionsWithoutMessage
        case .fetchEntitlements(let message):
            return message
        case .invalidReceipt:
            return Localizations.RevenueMoreError.Description.invalidReceipt
        case .badURL:
            return Localizations.RevenueMoreError.Description.badURL
        }
    }
    
    /// A localized message describing the reason for the failure.
    public var failureReason: String? {
        switch self {
        case .unexpected:
            return Localizations.RevenueMoreError.Reason.unexpected
        case .notFoundOffering:
            return Localizations.RevenueMoreError.Reason.notFoundOffering
        case .notFoundProduct:
            return Localizations.RevenueMoreError.Reason.notFoundProduct
        case .fetchPaywalls:
            return Localizations.RevenueMoreError.Reason.fetchPaywalls
        case .notInitializedStoreKit1Manager, .notInitializedStoreKit2Manager:
            return Localizations.RevenueMoreError.Reason.notInitializeStoreKitManager
        case .notFoundStoreProduct:
            return Localizations.RevenueMoreError.Reason.notFoundStoreProduct
        case .notFoundProductIDs:
            return Localizations.RevenueMoreError.Reason.notFoundProductIds
        case .fetchProductFailed:
            return Localizations.RevenueMoreError.Reason.fetchProductFailed
        case .notFoundWindowScene:
            return Localizations.RevenueMoreError.Reason.notFoundWindowScene
        case .notShowManageSubscriptions, .notShowManageSubscriptionsWithoutMessage:
            return Localizations.RevenueMoreError.Reason.notShowManageSubscriptions
        case .restorePaymentFailed:
            return Localizations.RevenueMoreError.Reason.restorePaymentFailed
        case .listenPaymentFailed, .purhaseFailed:
            return Localizations.RevenueMoreError.Reason.listenPaymentFailed
        case .purchaseCanceledByUser:
            return Localizations.RevenueMoreError.Reason.purchaseCanceledByUser
        case .purchaseIsPending:
            return Localizations.RevenueMoreError.Reason.purhaseIsPending
        case .purhaseFailedWithoutMessage:
            return Localizations.RevenueMoreError.Reason.purchaseFailedWithoutMessage
        case .transactionListenerUnverified:
            return Localizations.RevenueMoreError.Reason.transactionListenerUnverified
        case .paymentCompletedWithFailure:
            return Localizations.RevenueMoreError.Reason.paymentComletedWithFailure
        case .fetchEntitlements:
            return Localizations.RevenueMoreError.Reason.fetchEntitlements
        case .invalidReceipt:
            return Localizations.RevenueMoreError.Reason.invalidReceipt
        case .badURL:
            return Localizations.RevenueMoreError.Reason.badURL
        }
    }
    
    /// A localized message describing how one might recover from the failure.
    public var recoverySuggestion: String? {
        switch self {
        case .unexpected:
            return Localizations.RevenueMoreError.RecoverySuggestion.unexpected
        case .notFoundOffering:
            return Localizations.RevenueMoreError.RecoverySuggestion.notFoundOffering
        case .notFoundProduct:
            return Localizations.RevenueMoreError.RecoverySuggestion.notFoundProduct
        case .fetchPaywalls:
            return Localizations.RevenueMoreError.RecoverySuggestion.fetchPaywalls
        case .notInitializedStoreKit1Manager, .notInitializedStoreKit2Manager:
            return Localizations.RevenueMoreError.RecoverySuggestion.notInitializedStoreKitManager
        case .notFoundStoreProduct:
            return Localizations.RevenueMoreError.RecoverySuggestion.notFoundStoreProduct
        case .notFoundProductIDs:
            return Localizations.RevenueMoreError.RecoverySuggestion.notFoundProductIds
        case .fetchProductFailed:
            return Localizations.RevenueMoreError.RecoverySuggestion.fetchProductFailed
        case .notFoundWindowScene:
            return Localizations.RevenueMoreError.RecoverySuggestion.notFoundWindowScene
        case .notShowManageSubscriptions, .notShowManageSubscriptionsWithoutMessage:
            return Localizations.RevenueMoreError.RecoverySuggestion.notShowManageSubscriptions
        case .restorePaymentFailed:
            return Localizations.RevenueMoreError.RecoverySuggestion.restorePaymentFailed
        case .listenPaymentFailed, .purhaseFailed:
            return Localizations.RevenueMoreError.RecoverySuggestion.listenPaymentFailed
        case .purchaseCanceledByUser:
            return Localizations.RevenueMoreError.RecoverySuggestion.purchaseCanceledByUser
        case .purchaseIsPending:
            return Localizations.RevenueMoreError.RecoverySuggestion.purchaseIsPending
        case .purhaseFailedWithoutMessage:
            return Localizations.RevenueMoreError.RecoverySuggestion.purshaseFailedWithoutMessage
        case .transactionListenerUnverified:
            return Localizations.RevenueMoreError.RecoverySuggestion.transactionListenerUnverified
        case .paymentCompletedWithFailure:
            return Localizations.RevenueMoreError.RecoverySuggestion.paymentCompletedWithFailure
        case .fetchEntitlements:
            return Localizations.RevenueMoreError.RecoverySuggestion.fetchEntitlements
        case .invalidReceipt:
            return Localizations.RevenueMoreError.RecoverySuggestion.invalidReceipt
        case .badURL:
            return Localizations.RevenueMoreError.RecoverySuggestion.badURL
        }
    }
}

extension RevenueMoreErrorInternal: CustomStringConvertible {
    
    /// A string representation of the error, which can be displayed in logs or error messages.
    public var description: String {
        switch self {
        case .unexpected:
            return Localizations.RevenueMoreError.Description.unexpected
        case .notFoundOffering:
            return Localizations.RevenueMoreError.Description.notFoundOffering
        case .notFoundProduct:
            return Localizations.RevenueMoreError.Description.notFoundProduct
        case .fetchPaywalls(let message):
            return message
        case .notInitializedStoreKit1Manager:
            return Localizations.RevenueMoreError.Description.notInitializedStoreKit1Manager
        case .notInitializedStoreKit2Manager:
            return Localizations.RevenueMoreError.Description.notInitializedStoreKit2Manager
        case .notFoundStoreProduct:
            return Localizations.RevenueMoreError.Description.notFoundStoreProduct
        case .notFoundProductIDs:
            return Localizations.RevenueMoreError.Description.notFoundProductIds
        case .fetchProductFailed(let message):
            return message
        case .notFoundWindowScene:
            return Localizations.RevenueMoreError.Description.notFoundWindowScene
        case .notShowManageSubscriptions(let message):
            return message ?? "Manage subscription view hasn't shown"
        case .notShowManageSubscriptionsWithoutMessage:
            return Localizations.RevenueMoreError.Description.notShowManageSubscriptionsWithoutMessage
        case .restorePaymentFailed(let message):
            return message
        case .listenPaymentFailed(let message):
            return message
        case .purhaseFailed(let message):
            return message
        case .purchaseCanceledByUser:
            return Localizations.RevenueMoreError.Description.purchaseCanceledByUser
        case .purchaseIsPending:
            return Localizations.RevenueMoreError.Description.purchaseIsPending
        case .purhaseFailedWithoutMessage:
            return Localizations.RevenueMoreError.Description.purhaseFailedWitoutMessage
        case .transactionListenerUnverified:
            return Localizations.RevenueMoreError.Description.transactionListenerUnverified
        case .paymentCompletedWithFailure(let message):
            return message
        case .fetchEntitlements(let message):
            return message
        case .invalidReceipt:
            return Localizations.RevenueMoreError.Description.invalidReceipt
        case .badURL:
            return Localizations.RevenueMoreError.Description.badURL
        }
    }
}

extension RevenueMoreErrorInternal: CustomNSError {
    
    /// The domain string used for `NSError` bridging.
    public static var errorDomain: String {
        "RevenueMore"
    }
    
    /// An integer code representing the specific error case.
    ///
    /// This allows for error differentiation in Objective-C code or log outputs.
    public var errorCode: Int {
        switch self {
        case .unexpected:
            return 9999
        case .notFoundOffering:
            return 1001
        case .notFoundProduct:
            return 1002
        case .fetchPaywalls:
            return 1003
        case .notInitializedStoreKit1Manager:
            return 2001
        case .notInitializedStoreKit2Manager:
            return 2002
        case .notFoundStoreProduct:
            return 2003
        case .notFoundProductIDs:
            return 2004
        case .fetchProductFailed:
            return 2005
        case .notFoundWindowScene:
            return 3001
        case .notShowManageSubscriptions:
            return 3002
        case .notShowManageSubscriptionsWithoutMessage:
            return 3003
        case .restorePaymentFailed:
            return 2006
        case .listenPaymentFailed:
            return 2007
        case .purhaseFailed:
            return 2008
        case .purchaseCanceledByUser:
            return 2009
        case .purchaseIsPending:
            return 2010
        case .purhaseFailedWithoutMessage:
            return 2011
        case .transactionListenerUnverified:
            return 2012
        case .paymentCompletedWithFailure:
            return 1004
        case .fetchEntitlements:
            return 1005
        case .invalidReceipt:
            return 2013
        case .badURL:
            return 3004
        }
    }
    
    /// A dictionary of additional user info provided with the error.
    ///
    /// Includes the file and line number (via `#file` and `#line`) along with the localized description.
    public var errorUserInfo: [String: Any] {
        [
            "file": #file,
            "line": #line,
            NSLocalizedDescriptionKey: description
        ]
    }
}
