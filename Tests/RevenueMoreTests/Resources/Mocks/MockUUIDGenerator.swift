// 
//  See LICENSE.text for this project’s licensing information.
//
//  MockUUIDGenerator.swift
//
//  Created by Bilal Durnagöl on 14.12.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

@testable import RevenueMore

class MockUUIDGenerator: UUIDGenerator {
    var mockUUID: String = "mock-uuid"
    func generateUUID() -> String {
        return mockUUID
    }
}
