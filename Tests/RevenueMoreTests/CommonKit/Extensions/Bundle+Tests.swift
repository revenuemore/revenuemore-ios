// 
//  See LICENSE folder for this project’s licensing information.
//
//  Bundle+Tests.swift
//
//  Created by Bilal Durnagöl on 24.01.2025.
//
//  Copyright © 2025 RevenueMore. All rights reserved.
// 

import XCTest
@testable import RevenueMore

private final class BundleFinder {}

final class Bundle_Tests: XCTestCase {
    
    /// Test to verify that the `module` bundle is correctly loaded.
    func testModuleBundleLoading() {
        // Get the module bundle
        let bundle = Bundle.module
        
        // Assert that the bundle is not nil
        XCTAssertNotNil(bundle, "The bundle should not be nil")

        // Assert that the bundle contains the expected resource
        let resourceExists = bundle.path(forResource: "StoreConfiguration", ofType: "storekit") != nil
        XCTAssertTrue(resourceExists, "The bundle should contain the expected resource")

        // Print bundle path for debugging purposes
        print("Bundle path: \(bundle.bundlePath)")
    }

    /// Test to ensure fallback logic returns the correct bundle when the resource bundle is not found.
    func testModuleBundleFallback() {
        let fallbackBundle = Bundle(for: BundleFinder.self)
        
        // Assert that the fallback bundle is not nil
        XCTAssertNotNil(fallbackBundle, "Fallback bundle should not be nil")
        
        // Check if the bundle identifier contains the expected string (handling optional values safely)
        let bundleIdentifier = fallbackBundle.bundleIdentifier ?? ""
        XCTAssertTrue(bundleIdentifier.contains("RevenueMoreTests"),
                      "Fallback bundle identifier should contain the expected bundle name. Found: \(bundleIdentifier)")
    }

    /// Test to validate bundle name formation and resource accessibility
    func testBundlePathResolution() {
        let expectedBundleName = "RevenueMore_RevenueMore.bundle"
        
        // Check if the expected bundle path exists in potential locations
        let candidates = [
            Bundle.main.resourceURL,
            Bundle(for: BundleFinder.self).resourceURL
        ]
        
        var bundleFound = false
        
        for candidate in candidates {
            if let path = candidate?.appendingPathComponent(expectedBundleName),
               Bundle(url: path) != nil {
                bundleFound = true
                break
            }
        }

        XCTAssertTrue(bundleFound, "The expected bundle should be found in one of the search paths")
    }
}

