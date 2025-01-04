// 
//  See LICENSE.text for this project’s licensing information.
//
//  EntitlementManagerTests.swift
//
//  Created by Bilal Durnagöl on 28.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import XCTest
@testable import RevenueMore

class EntitlementManagerTests: XCTestCase {
    var sut: EntitlementManager!
    var mockSubscriptionsServices: MockSubscriptionServices!
    var mockUserServices: MockUserServices!
    var mockUserManager: MockUserManager!
    var mockBackendConfigurator: MockBackendConfigurator!
    var mockUserCache: MockUserCache!
    
    override func setUp() {
        super.setUp()
        mockSubscriptionsServices = MockSubscriptionServices()
        mockUserServices = MockUserServices()
        mockUserCache = MockUserCache()
        mockUserManager = MockUserManager(userCache: mockUserCache)
        mockBackendConfigurator = MockBackendConfigurator()
        
        sut = EntitlementManager(
            subscriptionsServices: mockSubscriptionsServices,
            userServices: mockUserServices,
            userManager: mockUserManager,
            backendConfigurator: mockBackendConfigurator
        )
    }
    
    override func tearDown() {
        super.tearDown()
        mockSubscriptionsServices = nil
        mockUserServices = nil
        mockUserManager = nil
        mockBackendConfigurator = nil
        mockUserCache = nil
        sut = nil
    }
    
    func testFetchEntitlements_Success() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch entitlements")
        
        // When
        sut.fetchEntitlements { result in
            // Then
            switch result {
            case .success(let entitlements):
                XCTAssertEqual(entitlements.allEntitlements.count, 1)
                XCTAssertEqual(entitlements.allEntitlements.first?.productId, "1m_rm_access")
            case .failure:
                XCTFail("Expected success but got failure")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testUpdateUserId_WhenUserIsAnonymous() {
        // Given
        let expectation = XCTestExpectation(description: "Update user ID")
        let testUserId = "test-user-123"
        mockUserManager.login(userId: nil)
        // When
        sut.updateUserId(userId: testUserId) {
            // Then
            XCTAssertTrue(self.mockBackendConfigurator.loginCalls.count == 1)
            XCTAssertTrue(self.mockUserServices.userUpdateCalled, "It should call user update")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testUpdateUserId_WhenUserIsNotAnonymous() {
        // Given
        let expectation = XCTestExpectation(description: "Update user ID")
        let testUserId = "test-user-123"
        mockUserManager.login(userId: testUserId)
        // When
        sut.updateUserId(userId: testUserId) {
            // Then
            XCTAssertTrue(self.mockBackendConfigurator.loginCalls.count == 1)
            XCTAssertFalse(self.mockUserServices.userUpdateCalled, "It shouldn't call user update")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
