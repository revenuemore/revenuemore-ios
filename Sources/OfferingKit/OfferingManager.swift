// 
//  See LICENSE.text for this project’s licensing information.
//
//  OfferingManager.swift
//
//  Created by Bilal Durnagöl on 7.09.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation
import StoreKit

/// A manager that handles fetching and presenting subscription offerings.
///
/// ``OfferingManager`` integrates with StoreKit 1 or StoreKit 2 managers (depending on the platform/version),
/// fetches paywalls (offerings) from your backend, retrieves the corresponding StoreKit products,
/// and finally aggregates them into an ``Offerings`` model for the app to display or use.
///
/// **Concurrency**:
/// - Marked `@unchecked Sendable` because it holds references (`paywallServices`, `userManager`, `storeKitManager`)
///   that must each be safe to use across concurrency domains.
internal class OfferingManager: @unchecked Sendable {
    
    // MARK: - Properties
    
    /// A service that handles paywall-related API calls, such as fetching available paywalls/subscriptions.
    private let paywallServices: PaywallServiceable
    
    /// A manager for user information (ID, anonymous login, etc.).
    private let userManager: UserManager
    
    /// A generic reference that could be either a `StoreKit1Manager` or a `StoreKit2Manager`,
    /// used for fetching and managing StoreKit products.
    private let storeKitManager: (any Sendable)
    
    // MARK: - Initialization
    
    /// Creates an ``OfferingManager`` with the specified services and StoreKit manager.
    ///
    /// - Parameters:
    ///   - paywallServices: A `PaywallServiceable` implementation for fetching paywall data from the backend.
    ///   - userManager: A `UserManager` responsible for current user context.
    ///   - forceFinishTransaction: A Boolean that may be used by some managers to automatically finish transactions.
    ///   - storeKitManager: A Sendable reference to either `StoreKit1Manager` or `StoreKit2Manager`.
    init(
        paywallServices: PaywallServiceable,
        userManager: UserManager,
        forceFinishTransaction: Bool,
        storeKitManager: (any Sendable)
    ) {
        self.paywallServices = paywallServices
        self.userManager = userManager
        self.storeKitManager = storeKitManager
    }
    
    // MARK: - Public Methods
    
    /// Fetches and returns the current offerings (paywalls/subscriptions).
    ///
    /// - Parameter completion: A closure returning ``Offerings`` on success or an error on failure.
    /// - Note: Internally calls `fetchPaywalls(completion:)` to retrieve the paywalls from the backend,
    ///   then fetches StoreKit products (StoreKit 1 or 2) and aggregates them.
    func getOfferings(completion: @escaping OfferingsClosure) {
        self.fetchPaywalls(completion: completion)
    }
    
    // MARK: - Helper Methods
    
    /// Fetches paywall information from the backend, then triggers product fetching.
    ///
    /// - Parameter completion: A closure returning an ``Offerings`` object on success or an error on failure.
    private func fetchPaywalls(completion: @escaping OfferingsClosure) {
        paywallServices.fetchPaywalls { [weak self] result in
            switch result {
            case .success(let response):
                self?.fetchProducts(response: response, completion: completion)
            case .failure(let error):
                completion(.failure(.fetchPaywalls(error.customMessage)))
            }
        }
    }
    
    /// Decides whether to fetch products using StoreKit 1 or StoreKit 2 based on platform availability.
    ///
    /// - Parameters:
    ///   - response: A `Paywalls.Response` representing the server’s paywall/subscription data.
    ///   - completion: A closure returning ``Offerings`` on success or an error on failure.
    private func fetchProducts(response: Paywalls.Response, completion: @escaping OfferingsClosure) {
        if #available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *) {
            fetchProducts(with: response, completion: completion)
        } else {
            fetchSKProducts(with: response, completion: completion)
        }
    }
    
    /// Fetches products via StoreKit 1 (for iOS <15, tvOS <15, etc.).
    ///
    /// - Parameters:
    ///   - paywallResponse: A `Paywalls.Response` describing available offerings.
    ///   - completion: A closure returning ``Offerings`` on success or an error on failure.
    private func fetchSKProducts(with paywallResponse: Paywalls.Response, completion: @escaping OfferingsClosure) {
        guard let offerings = paywallResponse.subscriptions else {
            💩("No offerings were found.")
            completion(.failure(.notFoundOffering))
            return
        }
        
        guard let storeKit1Manager = storeKitManager as? StoreKit1Manager else {
            completion(.failure(.notInitializedStoreKit1Manager))
            return
        }
        
        let packages = offerings.compactMap { $0.packages }.flatMap { $0 }
        let productIds = Set(packages.compactMap { $0.productId })
        
        storeKit1Manager.fetchProducts(with: productIds) { [weak self] result in
            switch result {
            case .success(let products):
                self?.presentOfferings(paywallResponse: paywallResponse, products: products, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Fetches products via StoreKit 2 (for iOS 15+, tvOS 15+, etc.).
    ///
    /// - Parameters:
    ///   - paywallResponse: A `Paywalls.Response` describing available offerings.
    ///   - completion: A closure returning ``Offerings`` on success or an error on failure.
    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    private func fetchProducts(with paywallResponse: Paywalls.Response, completion: @escaping OfferingsClosure) {
        guard let offerings = paywallResponse.subscriptions else {
            💩("No offerings were found.")
            completion(.failure(.notFoundOffering))
            return
        }
        
        guard let storeKit2Manager = storeKitManager as? StoreKit2Manager else {
            completion(.failure(.notInitializedStoreKit2Manager))
            return
        }
        
        let packages = offerings.compactMap { $0.packages }.flatMap { $0 }
        let productIds = Set(packages.compactMap { $0.productId })
        
        Task {
            do {
                let products = try await storeKit2Manager.fetchProducts(with: productIds)
                presentOfferings(paywallResponse: paywallResponse, products: products, completion: completion)
            } catch let error as RevenueMoreErrorInternal {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Presentation
    
    /// Merges the fetched paywalls with StoreKit products (StoreKit 1 or 2) to create an ``Offerings`` object.
    ///
    /// - Parameters:
    ///   - paywallResponse: The `Paywalls.Response` retrieved from the backend.
    ///   - products: An array of products, either `[Product]` (StoreKit 2) or `[SKProduct]` (StoreKit 1).
    ///   - completion: A closure returning ``Offerings`` on success or an error on failure.
    ///
    /// **Behavior**:
    /// 1. Validates there are subscriptions in the paywall response.
    /// 2. For StoreKit 2: casts products to `[Product]`.
    /// 3. For StoreKit 1: casts products to `[SKProduct]`.
    /// 4. Creates `Offering` objects by matching product identifiers to the corresponding packages.
    /// 5. Creates `OfferingTrigger` objects to link triggers to specific offerings.
    /// 6. Returns an ``Offerings`` object containing all offerings and triggers.
    private func presentOfferings(paywallResponse: Paywalls.Response, products: [Any], completion: @escaping OfferingsClosure) {
        
        guard let offerings = paywallResponse.subscriptions else {
            💩("No subscriptions were found.")
            completion(.failure(.notFoundOffering))
            return
        }
        
        let triggers = paywallResponse.triggers
        
        if #available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *) {
            // Handle StoreKit 2 products
            if let products = products as? [Product] {
                let offering = offerings.map { subscription in
                    Offering(
                        identifier: subscription.offeringId ?? "",
                        products: products.filter { product in
                            subscription.packages?.contains(where: { $0.productId == product.id }) ?? false
                        }.map {
                            RevenueMoreProduct(product: $0)
                        },
                        isCurrent: subscription.isCurrent ?? false
                    )
                }
                
                let triggers = triggers?.map { trigger in
                    OfferingTrigger(
                        identifier: trigger.triggerId ?? "",
                        offering: offering.first(where: { $0.identifier == trigger.offeringId }),
                        isCurrent: trigger.isCurrent ?? false
                    )
                }
                
                let offerings = Offerings(offerings: offering, triggers: triggers)
                completion(.success(offerings))
                
            } else {
                completion(.failure(.notFoundProduct))
            }
        } else {
            // Handle StoreKit 1 products
            if let products = products as? [SKProduct] {
                let offering = offerings.map { subscription in
                    Offering(
                        identifier: subscription.offeringId ?? "",
                        products: products.filter { product in
                            subscription.packages?.contains(where: { $0.productId == product.productIdentifier }) ?? false
                        }.map {
                            RevenueMoreProduct(skProduct: $0)
                        },
                        isCurrent: subscription.isCurrent ?? false
                    )
                }
                
                let triggers = triggers?.map { trigger in
                    OfferingTrigger(
                        identifier: trigger.triggerId ?? "",
                        offering: offering.first(where: { $0.identifier == trigger.offeringId }),
                        isCurrent: trigger.isCurrent ?? false
                    )
                }
                
                let offerings = Offerings(offerings: offering, triggers: triggers)
                completion(.success(offerings))
            } else {
                completion(.failure(.notFoundProduct))
            }
        }
    }
}
