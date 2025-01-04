// 
//  See LICENSE.text for this project’s licensing information.
//
//  UserServicesTests.swift
//
//  Created by Bilal Durnagöl on 28.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import XCTest
@testable import RevenueMore

final class UserServicesTests: XCTestCase {
    
    var mockServices: MockUserServices!

    // MARK: - Ovveride(s)
    
    override func setUp() {
        super.setUp()
        mockServices = MockUserServices()
    }
    
    override func tearDown() {
        super.tearDown()
        mockServices = nil
    }
    
    func testUserServices_WhenSetUserId_ReturnsTrue() {
        // Arrange
        let userId = "123456789"
        let request = UserUpdate.Request(userId: userId)
        
        // Act
        mockServices.userUpdate(request: request, completion: { result in
            switch result {
            case .success:
                // Assert
                XCTAssertTrue(true)
            case .failure:
                // Assert
                XCTFail()
            }
        })
    }
}
