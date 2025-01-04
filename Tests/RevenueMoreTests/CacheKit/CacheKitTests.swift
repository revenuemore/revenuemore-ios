// 
//  See LICENSE.text for this project’s licensing information.
//
//  CacheKitTests.swift
//
//  Created by Bilal Durnagöl on 20.06.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import XCTest
@testable import RevenueMore

class UserCacheTests: XCTestCase {
    var sut: MockUserCache!
    
    override func setUp() {
        super.setUp()
        sut = MockUserCache()
    }
    
    override func tearDown() {
        sut.clearCalls()
        sut.clearStorage()
        sut = nil
        super.tearDown()
    }
    
    func testUserId_WhenSet_StoresValueInStorage() {
        // Given
        let testUserId = "test-user-123"
        
        // When
        sut.userId = testUserId
        
        // Then
        XCTAssertEqual(sut.setCalls.count, 1)
        XCTAssertEqual(sut.setCalls.first?.key, UserCacheStorage.userId.rawValue)
        XCTAssertEqual(sut.setCalls.first?.value as? String, testUserId)
    }
    
    func testUserId_WhenGet_RetrievesValueFromStorage() {
        // Given
        sut.userId = "test-user-123"
        sut.clearCalls() // Clear previous calls
        
        // When
        let result = sut.userId
        
        // Then
        XCTAssertEqual(sut.getCalls.count, 1)
        XCTAssertEqual(sut.getCalls.first, UserCacheStorage.userId.rawValue)
        XCTAssertEqual(result, "test-user-123")
    }
    
    func testUuid_WhenSet_StoresValueInStorage() {
        // Given
        let testUuid = "test-uuid-456"
        
        // When
        sut.uuid = testUuid
        
        // Then
        XCTAssertEqual(sut.setCalls.count, 1)
        XCTAssertEqual(sut.setCalls.first?.key, UserCacheStorage.uuid.rawValue)
        XCTAssertEqual(sut.setCalls.first?.value as? String, testUuid)
    }
    
    func testLanguageCode_WhenSet_StoresValueInStorage() {
        // Given
        let testLanguage = "en-US"
        
        // When
        sut.languageCode = testLanguage
        
        // Then
        XCTAssertEqual(sut.setCalls.count, 1)
        XCTAssertEqual(sut.setCalls.first?.key, UserCacheStorage.languageCode.rawValue)
        XCTAssertEqual(sut.setCalls.first?.value as? String, testLanguage)
    }
}
