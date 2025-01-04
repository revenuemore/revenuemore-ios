// 
//  See LICENSE.text for this project’s licensing information.
//
//  SubscriptionServices.swift
//
//  Created by Bilal Durnagöl on 29.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

@testable import RevenueMore

final class MockSubscriptionServices: Mockable, SubscriptionServiceable {
    
    func complete(request: PaymentComplete.Request, completion: @escaping @Sendable (Result<PaymentComplete.Response, BaseError>) -> Void) {
        
    }
    
    func subscriptions(request: UserSubscription.Request, completion: @escaping @Sendable (Result<UserSubscription.Response, BaseError>) -> Void) {
        loadJSON(filename: "fetch_subscriptions_response", type: UserSubscription.Response.self, completion: completion)
    }
}
