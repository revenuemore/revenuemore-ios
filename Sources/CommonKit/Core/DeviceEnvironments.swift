// 
//  See LICENSE.text for this project’s licensing information.
//
//  DeviceEnvironments.swift
//
//  Created by Bilal Durnagöl on 8.04.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
import UIKit
import Foundation
import StoreKit
#elseif os(watchOS)
import UIKit
import WatchKit
import Foundation
import StoreKit
#elseif os(macOS)
import AppKit
import Foundation
import StoreKit
#endif

/// A class providing various environment-specific information about the current device and app.
///
/// `DeviceEnvironments` exposes static properties that allow you to:
///  - Retrieve app versions (`appVersion`, `buildNumber`, etc.).
///  - Determine platform details (`platform`, `deviceModel`, etc.).
///  - Check environment status (simulator, sandbox).
///  - Access StoreKit-related info such as the user's storefront country code.
class DeviceEnvironments: @unchecked Sendable {

    // MARK: - Properties
    
    /// The current version of the SDK.
    ///
    /// Change this value to reflect the SDK version you are distributing.
    static var sdkVersion: String {
        return "0.1.0"
    }

    /// The operating system version string of the current device.
    ///
    /// Obtains the version using `ProcessInfo().operatingSystemVersionString`.
    static var systemVersion: String {
        return ProcessInfo().operatingSystemVersionString
    }

    /// The short version string for the current application.
    ///
    /// Typically corresponds to the `"CFBundleShortVersionString"` in the main bundle’s `infoDictionary`.
    /// - Returns: A string describing the app version, or an empty string if not found.
    static var appVersion: String {
        guard
            let version: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        else {
            // Custom assertion or error logging
            💥("App version not found")
            return ""
        }
        return version
    }

    /// The build number (CFBundleVersion) of the current application.
    ///
    /// Typically found in the main bundle’s `infoDictionary`.
    /// - Returns: A string describing the build number, or an empty string if not found.
    static var buildNumber: String {
        guard
            let version: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        else {
            // Custom assertion or error logging
            💥("Number not found")
            return ""
        }
        return version
    }

    /// The bundle identifier of the current application.
    ///
    /// Obtained from `Bundle.main.bundleIdentifier`.
    /// - Returns: A string describing the bundle ID, or an empty string if not found.
    static var bundleId: String {
        guard
            let bundleId: String = Bundle.main.bundleIdentifier
        else {
            // Custom assertion or error logging
            💥("Bundle id not found")
            return ""
        }
        return bundleId
    }

    /// The name of the operating system or platform the app is running on.
    ///
    /// - Returns:
    ///   - `"macOS"` if running on macOS or Mac Catalyst.
    ///   - `"watchOS"` if running on watchOS.
    ///   - Otherwise, the system name from `UIDevice.current.systemName`.
    static var platform: String {
        #if os(macOS) || targetEnvironment(macCatalyst)
            return "macOS"
        #elseif os(watchOS)
            return "watchOS"
        #else
            return UIDevice.current.systemName
        #endif
    }

    /// The machine identifier of the current device.
    ///
    /// Uses the UNIX `uname` system call to retrieve the model (e.g., `"x86_64"`, `"iPhone14,3"`, etc.).
    /// - Returns: A string describing the raw device model identifier.
    static var deviceModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)

        let modelIdentifier = withUnsafePointer(to: &systemInfo.machine) { ptr in
            return String(cString: UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self))
        }

        return modelIdentifier
    }

    /// A Boolean value indicating whether the code is running in the simulator.
    ///
    /// Uses `#if targetEnvironment(simulator)` checks to determine if it's a simulator.
    /// - Returns: `true` if running in the simulator; otherwise, `false`.
    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }

    /// A Boolean value indicating whether the app is running in a sandbox environment.
    ///
    /// The method checks the app's receipt file location in the file system to determine
    /// whether it's running in a sandbox, non-sandbox, or simulator environment.
    /// - Returns:
    ///   - `true` if running in the simulator or if the receipt file path indicates a sandbox environment.
    ///   - `false` otherwise.
    static var isSandbox: Bool {
        guard !Self.isSimulator else { return true }

        guard let path = Bundle.main.appStoreReceiptURL?.path else { return false }

        if path.contains("MASReceipt/receipt") {
            return path.contains("Xcode/DerivedData")
        } else {
            return path.contains("sandboxReceipt")
        }
    }

    /// The two-letter country code associated with the user’s StoreKit storefront, if available.
    ///
    /// This property requires specific OS versions:
    /// - iOS 13.0 or later
    /// - macOS 10.15 or later
    /// - tvOS 13.0 or later
    /// - watchOS 6.2 or later
    /// - visionOS 1.0 or later
    ///
    /// - Returns:
    ///   - A `String` with the storefront’s country code (e.g., `"US"`, `"GB"`),
    ///   - `nil` if not available or if running on older OS versions.
    static var countryCode: String? {
        if #available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, visionOS 1.0, *) {
            return SKPaymentQueue.default().storefront?.countryCode
        } else {
            return nil
        }
    }
}
