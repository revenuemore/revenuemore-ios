// 
//  See LICENSE.text for this project’s licensing information.
//
//  MockUserCacheStorage.swift
//
//  Created by Bilal Durnagöl on 14.12.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

@testable import RevenueMore
import Foundation

class MockUserCacheStorage: UserCacheStorageProtocol {
    private var storage: [String: Any] = [:]
    private(set) var getCalls: [(String)] = []
    private(set) var setCalls: [(key: String, value: Any?)] = []
    
    func getString(forKey key: String) -> String? {
        getCalls.append((key))
        return storage[key] as? String
    }
    
    func setValue(_ value: Any?, forKey key: String) {
        setCalls.append((key: key, value: value))
        storage[key] = value
    }
    
    func clearCalls() {
        getCalls.removeAll()
        setCalls.removeAll()
    }
    
    func clearStorage() {
        storage.removeAll()
    }
}
