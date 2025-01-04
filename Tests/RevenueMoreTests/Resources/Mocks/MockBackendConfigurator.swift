// 
//  See LICENSE.text for this project’s licensing information.
//
//  MockBackendConfigurator.swift
//
//  Created by Bilal Durnagöl on 14.12.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation
@testable import RevenueMore

final class MockBackendConfigurator: BackendConfiguratorProtocol {
    // MARK: - Properties
    private(set) var apiKey: String
    private(set) var userId: String
    private(set) var userUUID: String
    
    // MARK: - Call Tracking
    private(set) var createHeadersCalled = false
    private(set) var loginCalls: [(userId: String, userUUID: String)] = []
    
    // MARK: - Mock Control
    var mockHeaders: HTTPHeaders?
    
    // MARK: - Initialization
    init(apiKey: String = "mock-api-key",
         userId: String = "mock-user-id",
         userUUID: String = "mock-uuid") {
        self.apiKey = apiKey
        self.userId = userId
        self.userUUID = userUUID
    }
    
    // MARK: - BackendConfiguratorProtocol Implementation
    func createHTTPHeaderFields() -> HTTPHeaders? {
        createHeadersCalled = true
        return mockHeaders
    }
    
    func login(userId: String, userUUID: String) {
        loginCalls.append((userId: userId, userUUID: userUUID))
        self.userId = userId
        self.userUUID = userUUID
    }
    
    // MARK: - Helper Methods
    func reset() {
        createHeadersCalled = false
        loginCalls.removeAll()
    }
}
