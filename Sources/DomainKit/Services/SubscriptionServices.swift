// 
//  See LICENSE.text for this project’s licensing information.
//
//  SubscriptionsServices.swift
//
//  Created by Bilal Durnagöl on 7.07.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

protocol SubscriptionServiceable {
    func complete(request: PaymentComplete.Request, completion: @Sendable @escaping (Result<PaymentComplete.Response, BaseError>) -> Void)
    func subscriptions(request: UserSubscription.Request, completion: @Sendable @escaping (Result<UserSubscription.Response, BaseError>) -> Void)
}

struct SubscriptionServices: HTTPClient, SubscriptionServiceable {

    var backendConfigurator: BackendConfigurator

    func complete(request: PaymentComplete.Request, completion: @Sendable @escaping (Result<PaymentComplete.Response, BaseError>) -> Void) {
        let endpoint = SubscriptionEndpoints.complete(request)
        let response = PaymentComplete.Response.self

        sendRequest(endpoint: endpoint, responseModel: response, completion: completion)
    }

    func subscriptions(request: UserSubscription.Request, completion: @Sendable @escaping (Result<UserSubscription.Response, BaseError>) -> Void) {
        let endpoint = SubscriptionEndpoints.subscriptions(request)
        let response = UserSubscription.Response.self

        sendRequest(endpoint: endpoint, responseModel: response, completion: completion)
    }
}
