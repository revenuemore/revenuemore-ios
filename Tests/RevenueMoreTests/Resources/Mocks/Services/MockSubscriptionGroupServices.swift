//
//  See LICENSE.text for this project's licensing information.
//
//  MockSubscriptionGroupServices.swift
//
//  Created by Bilal Durnagöl on 28.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

@testable import RevenueMore

final class MockSubscriptionGroupServices: Mockable, SubscriptionGroupServiceable {
    func fetchSubscriptionGroups(completion: @escaping @Sendable (Result<SubscriptionGroups.Response, BaseError>) -> Void) {
        loadJSON(filename: "subscription_groups_response", type: SubscriptionGroups.Response.self, completion: completion)
    }
}
