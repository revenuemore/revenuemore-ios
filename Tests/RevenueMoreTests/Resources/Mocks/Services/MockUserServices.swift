// 
//  See LICENSE.text for this project’s licensing information.
//
//  UserServicesMock.swift
//
//  Created by Bilal Durnagöl on 28.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

@testable import RevenueMore

final class MockUserServices: Mockable, UserServiceable {
    
    private(set) var userUpdateCalled: Bool = false
    
    func userUpdate(request: UserUpdate.Request, completion: @escaping @Sendable (Result<UserUpdate.Response, BaseError>) -> Void) {
        userUpdateCalled = true
        loadJSON(filename: "user_update_success_response", type: UserUpdate.Response.self, completion: completion)
    }
}
