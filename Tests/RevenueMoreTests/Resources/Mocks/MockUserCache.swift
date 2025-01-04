// 
//  See LICENSE.text for this project’s licensing information.
//
//  MockUserCache.swift
//
//  Created by Bilal Durnagöl on 14.12.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

@testable import RevenueMore

class MockUserCache: UserCache {
    private let mockStorage: MockUserCacheStorage
    
    init(mockStorage: MockUserCacheStorage = MockUserCacheStorage()) {
        self.mockStorage = mockStorage
        super.init(storage: mockStorage)
    }
    
    var getCalls: [(String)] {
        return mockStorage.getCalls
    }
    
    var setCalls: [(key: String, value: Any?)] {
        return mockStorage.setCalls
    }
    
    func clearCalls() {
        mockStorage.clearCalls()
    }
    
    func clearStorage() {
        mockStorage.clearStorage()
    }
}
