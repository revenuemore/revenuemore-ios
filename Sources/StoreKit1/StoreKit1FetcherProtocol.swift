// 
//  See LICENSE.text for this project’s licensing information.
//
//  StoreKit1FetcherProtocol.swift
//
//  Created by Bilal Durnagöl on 15.12.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import StoreKit

/// A protocol that defines a method for fetching products using StoreKit 1.
///
/// Conforming types are expected to implement the `fetchProducts(with:completion:)` method,
/// which should initiate a `SKProductsRequest` (or equivalent) and return a list of fetched products or an error.
protocol StoreKit1FetcherProtocol {
    
    /// Fetches products from the App Store for the given set of product identifiers.
    ///
    /// - Parameters:
    ///   - ids: A set of unique product identifiers (`String`) to be fetched.
    ///   - completion: A closure that is called when the fetch operation completes.
    ///     - On success, provides an array of `RM1Product` (often an alias or wrapper around `SKProduct`).
    ///     - On failure, provides a `RevenueMoreErrorInternal` indicating the reason for failure (e.g., invalid IDs, network error).
    ///
    /// **Usage Example**:
    /// ```swift
    /// let fetcher: StoreKit1FetcherProtocol = SomeFetcherImplementation()
    /// let productIDs: Set<String> = ["com.example.myapp.product1", "com.example.myapp.product2"]
    /// fetcher.fetchProducts(with: productIDs) { result in
    ///     switch result {
    ///     case .success(let products):
    ///         // Handle fetched products
    ///     case .failure(let error):
    ///         // Handle error
    ///     }
    /// }
    /// ```
    func fetchProducts(
        with ids: Set<String>,
        completion: @escaping @Sendable (Result<[RM1Product], RevenueMoreErrorInternal>) -> Void
    )
}

/// A protocol describing the minimum interface for an object that can start a StoreKit 1 product request.
///
/// Conforming types should store a delegate (typically `SKProductsRequestDelegate`)
/// and implement a `start()` method to begin the request.
protocol ProductsRequestProtocol {
    
    /// A delegate that receives events about product requests, such as `productsRequest(_:didReceive:)`.
    var delegate: SKProductsRequestDelegate? { get set }
    
    /// Starts the product request.
    ///
    /// This method should initiate communication with the App Store to retrieve products.
    func start()
}

/// Makes `SKProductsRequest` conform to `ProductsRequestProtocol`.
///
/// By adopting this protocol, `SKProductsRequest` can be used in a more abstract context
/// where only `ProductsRequestProtocol` is required.
extension SKProductsRequest: ProductsRequestProtocol {}

/// A protocol for creating product request objects.
///
/// Conforming types should implement a method to create and return objects that conform to `ProductsRequestProtocol`.
protocol ProductRequestCreating {
    
    /// Creates a product request object for the given set of product identifiers.
    ///
    /// - Parameter productIdentifiers: A set of product IDs to be requested.
    /// - Returns: An object conforming to `ProductsRequestProtocol` (e.g., `SKProductsRequest`).
    func createRequest(productIdentifiers: Set<String>) -> ProductsRequestProtocol
}

/// A default implementation of `ProductRequestCreating` that creates `SKProductsRequest` objects.
///
/// `DefaultProductRequestCreator` returns a standard `SKProductsRequest` for the provided product identifiers.
struct DefaultProductRequestCreator: ProductRequestCreating {
    
    /// Creates an `SKProductsRequest` for the given set of product identifiers.
    ///
    /// - Parameter productIdentifiers: A set of product IDs to be fetched from the App Store.
    /// - Returns: An `SKProductsRequest` instance (conforming to `ProductsRequestProtocol`).
    ///
    /// **Usage Example**:
    /// ```swift
    /// let creator = DefaultProductRequestCreator()
    /// let request = creator.createRequest(productIdentifiers: ["com.example.app.product1"])
    /// // request is an SKProductsRequest ready to start
    /// ```
    func createRequest(productIdentifiers: Set<String>) -> ProductsRequestProtocol {
        return SKProductsRequest(productIdentifiers: productIdentifiers)
    }
}
