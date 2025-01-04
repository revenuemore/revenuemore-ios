// 
//  See LICENSE.text for this project’s licensing information.
//
//  UserManagerTests.swift
//
//  Created by Bilal Durnagöl on 14.12.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import XCTest
@testable import RevenueMore

final class UserManagerTests: XCTestCase {
    
    var sut: UserManager!
    var mockCache: MockUserCache!
    var mockUUIDGenerator: MockUUIDGenerator!
    
    override func setUp() {
        super.setUp()
        mockCache = MockUserCache()
        mockUUIDGenerator = MockUUIDGenerator()
        sut = UserManager(userCache: mockCache, uuidGenerator: mockUUIDGenerator)
    }
    
    func testLogin_WithNewUserId_GeneratesNewUUID() {
        // Given
        mockUUIDGenerator.mockUUID = "test-uuid"
        
        // When
        let result = sut.login(userId: "test-user")
        
        // Then
        XCTAssertEqual(result.userId, "test-user")
        XCTAssertEqual(result.uuid, "test-uuid")
        XCTAssertEqual(mockCache.userId, "test-user")
        XCTAssertEqual(mockCache.uuid, "test-uuid")
    }
    
    
}
