// 
//  See LICENSE.text for this project’s licensing information.
//
//  MockEntitlementManager.swift
//
//  Created by Bilal Durnagöl on 14.12.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation
@testable import RevenueMore

class MockEntitlementManager: EntitlementManagerProtocol {
    // MARK: - Call Tracking
    struct FunctionCall: Equatable {
        let name: String
        let parameters: [String: Any]
        
        static func == (lhs: FunctionCall, rhs: FunctionCall) -> Bool {
            return lhs.name == rhs.name
        }
    }
    
    private(set) var functionCalls: [FunctionCall] = []
    
    // MARK: - Mock Control
    var mockEntitlements: Result<Entitlements, RevenueMoreErrorInternal>?
    var mockUpdateUserIdDelay: TimeInterval = 0
    
    // MARK: - EntitlementManagerProtocol Implementation
    func fetchEntitlements(completion: @escaping @Sendable (Result<Entitlements, RevenueMoreErrorInternal>) -> Void) {
        functionCalls.append(FunctionCall(name: "fetchEntitlements", parameters: [:]))
        
        if let mockEntitlements = mockEntitlements {
            completion(mockEntitlements)
        }
    }
    
    func updateUserId(userId: String, completion: @escaping @Sendable () -> Void) {
        functionCalls.append(FunctionCall(name: "updateUserId", parameters: ["userId": userId]))
        
        if mockUpdateUserIdDelay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + mockUpdateUserIdDelay) {
                completion()
            }
        } else {
            completion()
        }
    }
    
    // MARK: - Helper Methods
    func clearCalls() {
        functionCalls.removeAll()
    }
    
    func wasMethodCalled(_ methodName: String) -> Bool {
        return functionCalls.contains { $0.name == methodName }
    }
    
    func getCallCount(_ methodName: String) -> Int {
        return functionCalls.filter { $0.name == methodName }.count
    }
    
    func getLastCall() -> FunctionCall? {
        return functionCalls.last
    }
}
