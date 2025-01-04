// 
//  See LICENSE.text for this project’s licensing information.
//
//  PaywallsServices.swift
//
//  Created by Bilal Durnagöl on 14.04.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

protocol PaywallServiceable {
    func fetchPaywalls(completion: @escaping @Sendable (Result<Paywalls.Response, BaseError>) -> Void)
}

struct PaywallServices: HTTPClient, PaywallServiceable {

    var backendConfigurator: BackendConfigurator

    func fetchPaywalls(completion: @escaping @Sendable (Result<Paywalls.Response, BaseError>) -> Void) {
        let endpoint = PaywallEndpoints.fetchPaywalls
        let response = Paywalls.Response.self

        sendRequest(endpoint: endpoint, responseModel: response) { result in
            switch result {
            case .success(let response):
                🗣("Offering count: \(response.subscriptions?.count ?? 0)")
                🗣("Offering ids fetched: \(response.subscriptions?.map { $0.offeringId ?? "" } ?? [])")
                🗣("Trigger count: \(response.triggers?.count ?? 0)")
                🗣("Trigger ids fetched: \(response.triggers?.map { $0.triggerId ?? "" } ?? [])")
                🗣("Product ids fetched: \(response.subscriptions?.map { $0.packages?.map { $0.productId ?? "" } ?? [] } ?? [])")
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
