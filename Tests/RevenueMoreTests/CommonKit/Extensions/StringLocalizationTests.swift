// 
//  See LICENSE.text for this project’s licensing information.
//
//  StringLocalizationTests.swift
//
//  Created by Bilal Durnagöl on 28.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import XCTest
@testable import RevenueMore

final class StringLocalizationTests: XCTestCase {
    
    var key = "unit_test_mock"

    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        super.tearDown()
        UserDefaults.standard.removeObject(forKey: UserCacheStorage.languageCode.rawValue)
    }

    func testLocalizationWithExistingLanguageCode() {
        // Arrange
        let mockLanguageCode = "en"
        UserDefaults.standard.set(mockLanguageCode, forKey: UserCacheStorage.languageCode.rawValue)

        // Expected translation for the mocked language
        let expectedTranslation = "English"
        
        // Act
        let localizedString = key.localized

        // Assert
        XCTAssertEqual(localizedString, expectedTranslation, "Localized string should match the expected translation for the given language code.")
    }

    func testLocalizationWithNonExistingLanguageCode() {
        // Arrange
        let mockLanguageCode = "nonexistent"
        UserDefaults.standard.set(mockLanguageCode, forKey: UserCacheStorage.languageCode.rawValue)

        // Expected translation from the default language
        let expectedDefaultTranslation = "English"

        // Act
        let localizedString = key.localized

        // Assert
        XCTAssertEqual(localizedString, expectedDefaultTranslation, "Localized string should fall back to the default bundle translation when the language code is invalid.")
    }

    func testLocalizationWithNoLanguageCodeSet() {
        // Expected translation from the default language
        let expectedDefaultTranslation = "English"

        // Act
        let localizedString = key.localized

        // Assert
        XCTAssertEqual(localizedString, expectedDefaultTranslation, "Localized string should use the default bundle translation when no language code is set.")
    }

    func testLocalizationFallbackToDefaultBundle() {
        // Arrange
        let mockLanguageCode = "fr" // French
        UserDefaults.standard.set(mockLanguageCode, forKey: UserCacheStorage.languageCode.rawValue)

        // Expected fallback translation from the default bundle
        let expectedDefaultTranslation = "English"

        // Act
        let localizedString = key.localized

        // Assert
        XCTAssertEqual(localizedString, expectedDefaultTranslation, "Localized string should fall back to the default bundle when the specified language code bundle is not found.")
    }
}
