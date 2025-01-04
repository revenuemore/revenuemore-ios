// 
//  See LICENSE.text for this project’s licensing information.
//
//  PaywallServicesMock.swift
//
//  Created by Bilal Durnagöl on 28.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

@testable import RevenueMore

final class MockPaywallServices: Mockable, PaywallServiceable {
    func fetchPaywalls(completion: @escaping @Sendable (Result<Paywalls.Response, BaseError>) -> Void) {
        loadJSON(filename: "paywalls_response", type: Paywalls.Response.self, completion: completion)
    }
}
