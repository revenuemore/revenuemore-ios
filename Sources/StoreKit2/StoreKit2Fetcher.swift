// 
//  See LICENSE.text for this project’s licensing information.
//
//  StoreKit2Fetcher.swift
//
//  Created by Bilal Durnagöl on 20.05.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

#if os(watchOS)
import StoreKit
import WatchKit
#else
import StoreKit
#endif

/// A class responsible for fetching products and managing subscriptions using StoreKit 2.
///
/// `StoreKit2Fetcher` provides asynchronous methods to fetch products
/// from the App Store (`fetchProducts(with:)`) and to display the
/// subscription management interface (`showManageSubscriptions()`)
/// on supported platforms.
///
/// **Concurrency**:
/// - Marked `@unchecked Sendable` to indicate it can be shared across
///   concurrency domains. Make sure to handle thread safety appropriately.
@available(iOS 15.0, tvOS 15.0, macOS 12.0, *)
internal class StoreKit2Fetcher: @unchecked Sendable {
    
    // MARK: - Product Fetching

    /// Fetches products from the App Store using StoreKit 2.
    ///
    /// - Parameter ids: A set of product identifiers to retrieve.
    /// - Returns: An array of `RM2Product` objects representing fetched products.
    /// - Throws:
    ///   - `RevenueMoreErrorInternal.notFoundProductIDs` if the provided set of IDs is empty.
    ///   - `RevenueMoreErrorInternal.fetchProductFailed` if StoreKit fails to return products.
    ///   - `RevenueMoreErrorInternal.notFoundStoreProduct` if no products match the requested IDs.
    ///
    /// **Usage**:
    /// ```swift
    /// do {
    ///     let products = try await storeKit2Fetcher.fetchProducts(with: ["com.example.myapp.product1"])
    ///     // Use the fetched products
    /// } catch {
    ///     // Handle errors
    /// }
    /// ```
    func fetchProducts(with ids: Set<String>) async throws -> [RM2Product] {
        🗣("Products fetching started.")

        guard !ids.isEmpty else {
            💥("Product ids not found.")
            throw RevenueMoreErrorInternal.notFoundProductIDs
        }

        var products = [RM2Product]()

        do {
            products = try await Product.products(for: ids)
        } catch {
            🍎("Can't fetch products from Store \(error.localizedDescription)")
            throw RevenueMoreErrorInternal.fetchProductFailed(error.localizedDescription)
        }

        if products.isEmpty {
            💥("StoreKit don't have any product.")
            throw RevenueMoreErrorInternal.notFoundStoreProduct
        }

        🗣("Product count: \(products.count)")

        products.forEach { product in
            🗣(String(
                format: "Product found: %@ %@ %@",
                product.id,
                product.displayName,
                product.displayPrice
            ))
        }

        return products
    }

    // MARK: - Subscription Management

    /// Displays the subscription management interface on supported platforms.
    ///
    /// - Important:
    ///   - Requires iOS 15.0, tvOS 15.0, or macOS 12.0 and later.
    ///   - Marked `@MainActor` due to UI interaction requirements on certain platforms.
    /// - Throws:
    ///   - `RevenueMoreErrorInternal.notShowManageSubscriptions(errorDescription)` if showing the subscriptions
    ///     interface fails with an associated message.
    ///   - `RevenueMoreErrorInternal.notFoundWindowScene` if no active `UIWindowScene` is found on iOS/macOS/catalyst.
    ///
    /// **Behavior**:
    /// - Depending on the platform, it calls different internal functions (`openSubscriptionManagement()`)
    ///   which might open a URL or use `AppStore.showManageSubscriptions(in:)`.
    @available(visionOS 1.0, *)
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    @MainActor
    func showManageSubscriptions() async throws {
        // Calls the AppStore.showManageSubscriptions method to display the subscription management interface.
        #if os(iOS) || os(visionOS) || targetEnvironment(macCatalyst)
        try await openSubscriptionManagement()
        #elseif os(macOS)
        try await openSubscriptionManagement()
        #elseif os(watchOS)
        try await openSubscriptionManagement()
        #endif
    }
}

@available(iOS 15.0, tvOS 15.0, macOS 12.0, *)
private extension StoreKit2Fetcher {
    
    // MARK: - iOS / Mac Catalyst / visionOS
    #if os(iOS) || os(visionOS) || targetEnvironment(macCatalyst)
    /// Opens the subscription management interface on iOS, macCatalyst, or visionOS.
    ///
    /// - Throws:
    ///   - `RevenueMoreErrorInternal.notShowManageSubscriptions(errorDescription)` if an error occurs
    ///     while calling `AppStore.showManageSubscriptions(in:)`.
    ///   - `RevenueMoreErrorInternal.notFoundWindowScene` if a valid `UIWindowScene` cannot be retrieved.
    func openSubscriptionManagement() async throws {
        if let windowScene = await UIApplication.shared.windowsScene {
            do {
                try await AppStore.showManageSubscriptions(in: windowScene)
            } catch {
                throw RevenueMoreErrorInternal.notShowManageSubscriptions(error.localizedDescription)
            }
        } else {
            throw RevenueMoreErrorInternal.notFoundWindowScene
        }
    }

    // MARK: - macOS
    #elseif os(macOS)
    /// Opens the subscription management interface on macOS by launching the
    /// App Store subscriptions URL.
    ///
    /// - Throws:
    ///   - `RevenueMoreErrorInternal.badURL` if the URL `https://apps.apple.com/account/subscriptions` cannot be formed.
    ///   - `RevenueMoreErrorInternal.notShowManageSubscriptionsWithoutMessage` if opening the URL fails.
    func openSubscriptionManagement() async throws {
        guard let url = URL(string: "https://apps.apple.com/account/subscriptions") else {
            💥("invalid URL: https://apps.apple.com/account/subscriptions")
            throw RevenueMoreErrorInternal.badURL
        }
        
        try await withCheckedThrowingContinuation { continuation in
            if NSWorkspace.shared.open(url) {
                continuation.resume()
            } else {
                continuation.resume(throwing: RevenueMoreErrorInternal.notShowManageSubscriptionsWithoutMessage)
            }
        }
    }

    // MARK: - watchOS
    #elseif os(watchOS)
    /// Opens the subscription management interface on watchOS via `WKExtension.shared().openManageSubscriptions(...)`.
    ///
    /// - Throws: `RevenueMoreErrorInternal.notShowManageSubscriptionsWithoutMessage` if `openManageSubscriptions` fails.
    func openSubscriptionManagement() async throws {
        try await withCheckedThrowingContinuation { continuation in
            WKExtension.shared().openManageSubscriptions { isOpen in
                if isOpen {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: RevenueMoreErrorInternal.notShowManageSubscriptionsWithoutMessage)
                }
            }
        }
    }
    #endif
}
