// 
//  See LICENSE.text for this project’s licensing information.
//
//  PaywallServicesTests.swift
//
//  Created by Bilal Durnagöl on 28.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import XCTest
@testable import RevenueMore

final class PaywallServicesTests: XCTestCase {
    
    var mockServices: MockPaywallServices!
    
    // MARK: - Override(s)
    
    override func setUp() {
        super.setUp()
        mockServices = MockPaywallServices()
    }
    
    override func tearDown() {
        super.tearDown()
        mockServices = nil
    }
    
    func testPaywallServices_WhenFetchPaywall_Returns2Subscription() {
        // Act
        mockServices.fetchPaywalls { result in
            switch result {
                case .success(let response):
                // Assert
                XCTAssertEqual(response.subscriptions?.count, 2, "Fetch paywall service should retunr 2 subscriptions, but returned \(response.subscriptions?.count ?? 0)")
            case .failure:
                // Assert
                XCTFail()
            }
        }
    }
}
