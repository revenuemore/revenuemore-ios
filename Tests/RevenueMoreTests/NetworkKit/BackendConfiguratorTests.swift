// 
//  See LICENSE.text for this project’s licensing information.
//
//  BackendConfiguratorTests.swift
//
//  Created by Bilal Durnagöl on 21.06.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import XCTest
@testable import RevenueMore

class MockDeviceEnvironment: DeviceEnvironmentProvider {
    var systemVersion = "15.0"
    var buildNumber = "123"
    var bundleId = "com.test.app"
    var platform = "iOS"
    var deviceModel = "iPhone13,1"
    var isSimulator = true
    var sdkVersion = "1.0.0"
    var isSandbox = true
    var countryCode: String? = "US"
}

class BackendConfiguratorTests: XCTestCase {
    var sut: BackendConfigurator!
    var mockEnvironment: MockDeviceEnvironment!
    
    override func setUp() {
        super.setUp()
        mockEnvironment = MockDeviceEnvironment()
        sut = BackendConfigurator(
            apiKey: "test-api-key",
            userId: "test-user-id",
            userUUID: "test-uuid",
            environment: mockEnvironment
        )
    }
    
    func testCreateHTTPHeaderFields_ContainsAllRequiredFields() {
        // When
        let headers = sut.createHTTPHeaderFields()
        
        // Then
        XCTAssertEqual(headers?["Authorization"], "test-api-key")
        XCTAssertEqual(headers?["osVersion"], "15.0")
        XCTAssertEqual(headers?["buildNumber"], "123")
        XCTAssertEqual(headers?["bundleId"], "com.test.app")
        XCTAssertEqual(headers?["platform"], "iOS")
        XCTAssertEqual(headers?["deviceModel"], "iPhone13,1")
        XCTAssertEqual(headers?["isSimulator"], "true")
        XCTAssertEqual(headers?["sdkVersion"], "1.0.0")
        XCTAssertEqual(headers?["isSandbox"], "true")
        XCTAssertEqual(headers?["storeCoutryCode"], "US")
        XCTAssertEqual(headers?["md"], "test-uuid")
        XCTAssertEqual(headers?["mr"], "test-user-id")
    }
    
    func testLogin_UpdatesUserCredentials() {
        // Given
        let newUserId = "new-user-id"
        let newUUID = "new-uuid"
        
        // When
        sut.login(userId: newUserId, userUUID: newUUID)
        
        // Then
        XCTAssertEqual(sut.userId, newUserId)
        XCTAssertEqual(sut.userUUID, newUUID)
    }
}
