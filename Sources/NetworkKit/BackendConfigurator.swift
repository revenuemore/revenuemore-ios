// 
//  See LICENSE.text for this project’s licensing information.
//
//  BackendConfigurator.swift
//
//  Created by Bilal Durnagöl on 20.06.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

protocol BackendConfiguratorProtocol {
    var apiKey: String { get }
    var userId: String { get }
    var userUUID: String { get }
    
    func createHTTPHeaderFields() -> HTTPHeaders?
    func login(userId: String, userUUID: String)
}

class BackendConfigurator: BackendConfiguratorProtocol, @unchecked Sendable {

    // MARK: - Properties
       private let environment: DeviceEnvironmentProvider
       private(set) var apiKey: String
       private(set) var userId: String
       private(set) var userUUID: String
       
    // MARK: - Initialization
    init(
        apiKey: String,
        userId: String,
        userUUID: String,
        environment: DeviceEnvironmentProvider = SystemDeviceEnvironment()
    ) {
        self.apiKey = apiKey
        self.userId = userId
        self.userUUID = userUUID
        self.environment = environment
    }

    // MARK: - Public Methods
    
    /// Creates HTTP header fields for API requests
    /// - Returns: Dictionary containing HTTP header fields
    open func createHTTPHeaderFields() -> HTTPHeaders? {
        return [
            "Content-Type": "application/json",
            "Authorization": apiKey,
            "osVersion": environment.systemVersion,
            "buildNumber": environment.buildNumber,
            "bundleId": environment.bundleId,
            "platform": environment.platform,
            "deviceModel": environment.deviceModel,
            "isSimulator": environment.isSimulator.description,
            "sdkVersion": environment.sdkVersion,
            "isSandbox": environment.isSandbox.description,
            "storeCoutryCode": environment.countryCode ?? "",
            "md": userUUID,
            "mr": userId
        ]
    }
    
    /// Updates the user credentials in the configurator
    /// - Parameters:
    ///   - userId: Unique identifier for the user
    ///   - userUUID: Unique UUID for the user's session
    open func login(userId: String, userUUID: String) {
        self.userId = userId
        self.userUUID = userUUID
    }
}
