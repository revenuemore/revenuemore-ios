// 
//  See LICENSE.text for this project’s licensing information.
//
//  DeviceEnvironmentProvider.swift
//
//  Created by Bilal Durnagöl on 14.12.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// A protocol that provides detailed information about the device and its environment.
///
/// `DeviceEnvironmentProvider` abstracts various device-specific and environment-specific details,
/// allowing different implementations to supply this information as needed. This can be particularly
/// useful for testing, where a mock environment provider might be used.
protocol DeviceEnvironmentProvider {
    
    /// The operating system version running on the device (e.g., "16.4").
    var systemVersion: String { get }
    
    /// The build number of the operating system (e.g., "20E241").
    var buildNumber: String { get }
    
    /// The bundle identifier of the application (e.g., "com.example.myapp").
    var bundleId: String { get }
    
    /// The platform the application is running on (e.g., "iOS", "macOS").
    var platform: String { get }
    
    /// The model identifier of the device (e.g., "iPhone14,2").
    var deviceModel: String { get }
    
    /// A Boolean indicating whether the application is running in a simulator environment.
    var isSimulator: Bool { get }
    
    /// The SDK version the application is built against (e.g., "16.4").
    var sdkVersion: String { get }
    
    /// A Boolean indicating whether the application is running in a sandbox environment.
    var isSandbox: Bool { get }
    
    /// The country code associated with the device's locale settings (e.g., "US", "GB").
    ///
    /// Returns `nil` if the country code is unavailable or cannot be determined.
    var countryCode: String? { get }
}

/// A concrete implementation of `DeviceEnvironmentProvider` that retrieves environment details
/// from the system.
///
/// `SystemDeviceEnvironment` accesses static properties from `DeviceEnvironments` to provide
/// real-time information about the device and its environment. This struct is suitable for use
/// in production environments where actual device data is required.
struct SystemDeviceEnvironment: DeviceEnvironmentProvider {
    
    /// The operating system version running on the device (e.g., "16.4").
    var systemVersion: String { DeviceEnvironments.systemVersion }
    
    /// The build number of the operating system (e.g., "20E241").
    var buildNumber: String { DeviceEnvironments.buildNumber }
    
    /// The bundle identifier of the application (e.g., "com.example.myapp").
    var bundleId: String { DeviceEnvironments.bundleId }
    
    /// The platform the application is running on (e.g., "iOS", "macOS").
    var platform: String { DeviceEnvironments.platform }
    
    /// The model identifier of the device (e.g., "iPhone14,2").
    var deviceModel: String { DeviceEnvironments.deviceModel }
    
    /// A Boolean indicating whether the application is running in a simulator environment.
    var isSimulator: Bool { DeviceEnvironments.isSimulator }
    
    /// The SDK version the application is built against (e.g., "16.4").
    var sdkVersion: String { DeviceEnvironments.sdkVersion }
    
    /// A Boolean indicating whether the application is running in a sandbox environment.
    var isSandbox: Bool { DeviceEnvironments.isSandbox }
    
    /// The country code associated with the device's locale settings (e.g., "US", "GB").
    ///
    /// Returns `nil` if the country code is unavailable or cannot be determined.
    var countryCode: String? { DeviceEnvironments.countryCode }
}
