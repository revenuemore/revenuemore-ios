//
//  See LICENSE.text for this project's licensing information.
//
//  SubscriptionGroupServicesTests.swift
//
//  Created by Bilal Durnagöl on 28.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import XCTest
@testable import RevenueMore

final class SubscriptionGroupServicesTests: XCTestCase {

    var mockServices: MockSubscriptionGroupServices!

    // MARK: - Override(s)

    override func setUp() {
        super.setUp()
        mockServices = MockSubscriptionGroupServices()
    }

    override func tearDown() {
        super.tearDown()
        mockServices = nil
    }

    func testSubscriptionGroupServices_WhenFetchSubscriptionGroups_Returns2SubscriptionGroups() {
        // Act
        mockServices.fetchSubscriptionGroups { result in
            switch result {
                case .success(let response):
                // Assert
                XCTAssertEqual(response.subscriptionGroups?.count, 2, "Fetch subscription groups service should return 2 subscription groups, but returned \(response.subscriptionGroups?.count ?? 0)")
            case .failure:
                // Assert
                XCTFail()
            }
        }
    }
}
