// 
//  See LICENSE.text for this project’s licensing information.
//
//  Localizations.swift
//
//  Created by Bilal Durnagöl on 22.10.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

enum Localizations { }

// MARK: - Errors

extension Localizations {
    enum RevenueMoreError {
        static var notInitialize: String = "not_initialize".localized
    }
}

// MARK: - Error Reasons
extension Localizations.RevenueMoreError {
    enum Reason {
        static var fetchEntitlements: String = "error.fetch_entitlements.reason".localized
        static var fetchPaywalls: String = "error.fetch_paywalls.reason".localized
        static var fetchProductFailed: String = "error.fetch_product_failed.reason".localized
        static var listenPaymentFailed: String = "error.listen_payment_failed.reason".localized
        static var notFoundOffering: String = "error.not_found_offering.reason".localized
        static var notFoundProductIds: String = "error.not_found_product_ids.reason".localized
        static var notFoundProduct: String = "error.not_found_product.reason".localized
        static var notFoundStoreProduct: String = "error.not_found_store_product.reason".localized
        static var notFoundWindowScene: String = "error.not_found_window_scene.reason".localized
        static var notInitializeStoreKitManager: String = "error.not_initialize_store_kit_manager.reason".localized
        static var notShowManageSubscriptions: String = "error.not_show_manage_subscriptions.reason".localized
        static var paymentComletedWithFailure: String = "error.payment_comleted_with_failure.reason".localized
        static var purchaseCanceledByUser: String = "error.purchase_canceled_by_user.reason".localized
        static var purhaseIsPending: String = "error.purhase_is_pending.reason".localized
        static var purchaseFailedWithoutMessage: String = "error.purchase_failed_without_message.reason".localized
        static var restorePaymentFailed: String = "error.restore_payment_failed.reason".localized
        static var transactionListenerUnverified: String = "error.transaction_listener_unverified.reason".localized
        static var unexpected: String = "error.unexpected.reason".localized
        static var invalidReceipt: String = "error.invalid_receipt.reason".localized
        static var badURL: String = "error.bad_url.reason".localized
    }
}

// MARK: - Error Description
extension Localizations.RevenueMoreError {
    enum Description {
        static var notFoundOffering: String = "error.not_found_offering.description".localized
        static var notFoundProductIds: String = "error.not_found_product_ids.description".localized
        static var notFoundProduct: String = "error.not_found_product.description".localized
        static var notFoundStoreProduct: String = "error.not_found_store_product.description".localized
        static var notFoundWindowScene: String = "error.not_found_window_scene.description".localized
        static var notInitializedStoreKit1Manager: String = "error.not_initialized_store_kit1_manager.description".localized
        static var notInitializedStoreKit2Manager: String = "error.not_initialized_store_kit2_manager.description".localized
        static var notShowManageSubscriptionsWithoutMessage: String = "error.not_show_manage_subscriptions_without_message.description".localized
        static var purchaseCanceledByUser: String = "error.purchase_canceled_by_user.description".localized
        static var purchaseIsPending: String = "error.purchase_is_pending.description".localized
        static var purhaseFailedWitoutMessage: String = "error.purhase_failed_without_message.description".localized
        static var transactionListenerUnverified: String = "error.transaction_listener_unverified.description".localized
        static var unexpected: String = "error.unexpected.description".localized
        static var invalidReceipt: String = "error.invalid_receipt.description".localized
        static var badURL: String = "error.bad_url.description".localized
    }
}

extension Localizations.RevenueMoreError {
    enum RecoverySuggestion {
        static var fetchEntitlements: String = "error.fetch_entitlements.recovery_suggestion".localized
        static var fetchPaywalls: String = "error.fetch_paywalls.recovery_suggestion".localized
        static var fetchProductFailed: String = "error.fetch_product_failed.recovery_suggestion".localized
        static var listenPaymentFailed: String = "error.listen_payment_failed.recovery_suggestion".localized
        static var notFoundOffering: String = "error.not_found_offering.recovery_suggestion".localized
        static var notFoundProductIds: String = "error.not_found_product_ids.recovery_suggestion".localized
        static var notFoundProduct: String = "error.not_found_product.recovery_suggestion".localized
        static var notFoundStoreProduct: String = "error.not_found_store_product.recovery_suggestion".localized
        static var notFoundWindowScene: String = "error.not_found_window_scene.recovery_suggestion".localized
        static var notInitializedStoreKitManager: String = "error.not_initialized_store_kit_manager.recovery_suggestion".localized
        static var notShowManageSubscriptions: String = "error.not_show_manage_subscriptions.recovery_suggestion".localized
        static var paymentCompletedWithFailure: String = "error.payment_completed_with_failure.recovery_suggestion".localized
        static var purchaseCanceledByUser: String = "error.purchase_canceled_by_user.recovery_suggestion".localized
        static var purchaseIsPending: String = "error.purchase_is_pending.recovery_suggestion".localized
        static var purshaseFailedWithoutMessage: String = "error.purshase_failed_without_message.recovery_suggestion".localized
        static var restorePaymentFailed: String = "error.restore_payment_failed.recovery_suggestion".localized
        static var transactionListenerUnverified: String = "error.transaction_listener_unverified.recovery_suggestion".localized
        static var unexpected: String = "error.unexpected.recovery_suggestion".localized
        static var invalidReceipt: String = "error.invalid_receipt.recovery_suggestion".localized
        static var badURL: String = "error.bad_url.recovery_suggestion".localized
    }
}
