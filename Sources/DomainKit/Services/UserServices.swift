// 
//  See LICENSE.text for this project’s licensing information.
//
//  UserServices.swift
//
//  Created by Bilal Durnagöl on 17.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

protocol UserServiceable {
    func userUpdate(request: UserUpdate.Request, completion: @Sendable @escaping (Result<UserUpdate.Response, BaseError>) -> Void)
}

struct UserServices: HTTPClient, UserServiceable {
    
    var backendConfigurator: BackendConfigurator
    
    func userUpdate(request: UserUpdate.Request, completion: @Sendable @escaping (Result<UserUpdate.Response, BaseError>) -> Void) {
        let endpoint = UserEndpoints.userUpdate(request)
        let response = UserUpdate.Response.self
        
        sendRequest(endpoint: endpoint, responseModel: response, completion: completion)
    }
}
