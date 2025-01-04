// 
//  See LICENSE.text for this project’s licensing information.
//
//  StoreKit1Fetcher.swift
//
//  Created by Bilal Durnagöl on 12.04.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import StoreKit
import Foundation

/// A class responsible for fetching products using StoreKit 1.
///
/// `StoreKit1Fetcher` implements `StoreKit1FetcherProtocol` and uses
/// `SKProductsRequest` to retrieve product information. It also delegates
/// product request callbacks to itself to handle responses and errors.
internal class StoreKit1Fetcher: NSObject, StoreKit1FetcherProtocol, @unchecked Sendable {

    // MARK: - Private Properties

    /// A `DispatchQueue` used to ensure thread-safe operations when fetching products.
    private let queue: DispatchQueue

    /// An object capable of creating `SKProductsRequest` instances.
    private let requestCreator: ProductRequestCreating

    /// The current request being processed. Once the request is completed, this is set to `nil`.
    private var currentRequest: ProductsRequestProtocol?

    /// A completion handler called when the product request finishes or fails.
    ///
    /// This closure is set in `fetchProducts(with:completion:)` and
    /// stored so it can be invoked once the request completes.
    var onReceiveCompletionHandler: ((Result<[SKProduct], RevenueMoreErrorInternal>) -> Void)?

    // MARK: - Initialization

    /// Initializes a new `StoreKit1Fetcher`.
    ///
    /// - Parameters:
    ///   - queue: A `DispatchQueue` where product fetch operations take place.
    ///            Defaults to a dedicated queue named `Constants.Queue.FETCHER_SK1`.
    ///   - requestCreator: An object conforming to `ProductRequestCreating`, responsible
    ///                     for creating `SKProductsRequest` objects. Defaults to `DefaultProductRequestCreator()`.
    init(
        queue: DispatchQueue = DispatchQueue(label: Constants.Queue.FETCHER_SK1),
        requestCreator: ProductRequestCreating = DefaultProductRequestCreator()
    ) {
        self.queue = queue
        self.requestCreator = requestCreator
        super.init()
    }

    // MARK: - Public Methods

    /// Fetches products from the App Store using a set of product identifiers.
    ///
    /// - Parameters:
    ///   - ids: A `Set<String>` of product identifiers to fetch.
    ///   - completion: A closure that returns a `Result` containing:
    ///     - `[RM1Product]` on success, where each `RM1Product` is a typealias or wrapper for `SKProduct`.
    ///     - `RevenueMoreErrorInternal` on failure, indicating why the product request failed.
    ///
    /// **Behavior**:
    /// 1. Ensures the set of product identifiers (`ids`) is not empty.
    /// 2. If empty, calls the completion handler with `.failure(.notFoundProductIDs)`.
    /// 3. Otherwise, creates a product request using `requestCreator`, sets `self` as its delegate,
    ///    stores the request in `currentRequest`, and starts the request.
    ///
    /// **Thread Safety**:
    /// - All operations are dispatched onto `queue` to serialize product request events.
    ///
    /// **Example**:
    /// ```swift
    /// storeKit1Fetcher.fetchProducts(with: ["com.example.product1", "com.example.product2"]) { result in
    ///     switch result {
    ///     case .success(let products):
    ///         // Process fetched products
    ///     case .failure(let error):
    ///         // Handle error
    ///     }
    /// }
    /// ```
    func fetchProducts(
        with ids: Set<String>,
        completion: @escaping @Sendable (Result<[RM1Product], RevenueMoreErrorInternal>) -> Void
    ) {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.onReceiveCompletionHandler = completion

            🗣("Products fetching started.")

            // If no product IDs are provided, return immediately with an error.
            guard !ids.isEmpty else {
                💥("Product ids not found.")
                completion(.failure(.notFoundProductIDs))
                return
            }

            // Create and start the product request.
            var request = self.requestCreator.createRequest(productIdentifiers: ids)
            request.delegate = self
            self.currentRequest = request
            request.start()
        }
    }
}

// MARK: - SKProductsRequestDelegate

extension StoreKit1Fetcher: SKProductsRequestDelegate {

    /// Handles the successful reception of product information.
    ///
    /// This method is called by the StoreKit framework on the delegate
    /// once the product request has completed.
    ///
    /// - Parameters:
    ///   - request: The `SKProductsRequest` instance that generated the response.
    ///   - response: An `SKProductsResponse` containing valid products and any invalid identifiers.
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.handleProductsResponse(response)
            self.currentRequest = nil
        }
    }
    
    // MARK: - Private Methods

    /// Processes the `SKProductsResponse` received from the App Store.
    ///
    /// - Parameter response: The response containing:
    ///   - `response.products`: A list of valid `SKProduct` objects.
    ///   - `response.invalidProductIdentifiers`: Any product identifiers that were rejected or unrecognized by the App Store.
    ///
    /// **Behavior**:
    /// 1. If `response.products` is empty, completes with `.failure(.notFoundStoreProduct)`.
    /// 2. Logs any invalid product identifiers if present.
    /// 3. Logs debug information about fetched products, including their identifiers, titles, and prices.
    /// 4. Calls the stored `onReceiveCompletionHandler` with `.success(response.products)`.
    private func handleProductsResponse(_ response: SKProductsResponse) {
        if response.products.isEmpty {
            💥("StoreKit don't have any product.")
            self.onReceiveCompletionHandler?(.failure(.notFoundStoreProduct))
        }

        if !response.invalidProductIdentifiers.isEmpty {
            let invalidIds = response.invalidProductIdentifiers.joined(separator: ", ")
            💥("InvalidProductIdentifiers: \(invalidIds)")
        }

        🗣("Product count: \(response.products.count)")
        
        // Log each valid product’s info for debugging or analytics purposes.
        response.products.forEach { product in
            🗣(String(
                format: "Product found: %@ %@ %f",
                product.productIdentifier,
                product.localizedTitle,
                product.price.doubleValue
            ))
        }

        // If any products were fetched, call success with the products array.
        self.onReceiveCompletionHandler?(.success(response.products))
    }
}
