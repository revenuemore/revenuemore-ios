//
//  See LICENSE.text for this project's licensing information.
//
//  SubscriptionGroupServices.swift
//
//  Created by Bilal Durnagöl on 14.04.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

protocol SubscriptionGroupServiceable {
    func fetchSubscriptionGroups(completion: @escaping @Sendable (Result<SubscriptionGroups.Response, BaseError>) -> Void)
}

struct SubscriptionGroupServices: HTTPClient, SubscriptionGroupServiceable {

    var backendConfigurator: BackendConfigurator

    func fetchSubscriptionGroups(completion: @escaping @Sendable (Result<SubscriptionGroups.Response, BaseError>) -> Void) {
        let endpoint = SubscriptionGroupEndpoints.fetchSubscriptionGroups
        let response = SubscriptionGroups.Response.self

        sendRequest(endpoint: endpoint, responseModel: response) { result in
            switch result {
            case .success(let response):
                🗣("Subscription group count: \(response.subscriptionGroups?.count ?? 0)")
                🗣("Subscription group ids fetched: \(response.subscriptionGroups?.map { $0.subscriptionGroupId ?? "" } ?? [])")
                // Triggers disabled for now
                // 🗣("Trigger count: \(response.triggers?.count ?? 0)")
                🗣("Product ids fetched: \(response.subscriptionGroups?.map { $0.products?.map { $0.productId ?? "" } ?? [] } ?? [])")
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
