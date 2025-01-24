// 
//  See LICENSE folder for this project’s licensing information.
//
//  Bundle+.swift
//
//  Created by Bilal Durnagöl on 24.01.2025.
//
//  Copyright © 2025 RevenueMore. All rights reserved.
// 

import Foundation

/// This extension provides helper methods to locate and load a `Bundle`
/// containing the resources when CocoaPods integration is used or
/// when Swift Package Manager (SPM) is not utilized.
#if COCOAPODS || !SWIFT_PACKAGE

extension Bundle {

    /// A static variable that returns the `Bundle` containing the application's resources.
    ///
    /// This property searches for the resource bundle using the following steps:
    /// 1. It first checks the resources in the main application bundle using `Bundle.main.resourceURL`.
    /// 2. Next, it looks for the resources in the module where this class is defined.
    /// 3. If the resource bundle is found, it is loaded using the specified bundle name (`RevenueMore_RevenueMore.bundle`).
    ///
    /// If the specified bundle cannot be found, the bundle where the `BundleFinder` class is located is returned as a fallback.
    ///
    /// - Returns: A `Bundle` instance containing the required resources.
    static let module: Bundle = {
        // List of potential locations to search for the bundle
        let candidates = [
            Bundle.main.resourceURL,                      // Main application bundle path
            Bundle(for: BundleFinder.self).resourceURL     // Current class's bundle path
        ]

        // Bundle name generated by CocoaPods
        let bundleName = "RevenueMore_RevenueMore"

        // Iterate through the potential locations to find the bundle
        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle  // Return the bundle if found
            }
        }

        // If the bundle is not found, return the bundle containing the current class
        return Bundle(for: BundleFinder.self)
    }()
}

/// An empty helper class used to determine the location of the bundle.
/// This class serves as a reference point to retrieve the bundle.
private final class BundleFinder {}

#endif
