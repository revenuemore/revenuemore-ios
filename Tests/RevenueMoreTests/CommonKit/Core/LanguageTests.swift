// 
//  See LICENSE.text for this project’s licensing information.
//
//  LanguageTests.swift
//
//  Created by Bilal Durnagöl on 28.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import XCTest
@testable import RevenueMore

final class LanguageTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testLanguageCode_WhenUseEnum_ReturnsCorrectCode() {
        // Assert
        XCTAssertEqual(Language.english.code, "en")
        XCTAssertEqual(Language.turkish.code, "tr")
    }
    
    func testLanguageCode_WhenUseString_ReturnsCorrectType() {
        // Assert
        XCTAssertEqual(Language(languageCode: "en"), .english)
        XCTAssertEqual(Language(languageCode: "tr"), .turkish)
        XCTAssertEqual(Language(languageCode: "en-US"), .english)
        XCTAssertEqual(Language(languageCode: "tr-TR"), .turkish)
    }
    
    func testLanguageCode_WhenUseInvalidString_ReturnsNil() {
        // Assert
        XCTAssertNil(Language(languageCode: "invalid"))
    }
    
    func testLanguageCode_WhenUseEnum_ReturnsCorrectLanguageName() {
        // Assert
        XCTAssertEqual(Language.english.name, "English")
        XCTAssertEqual(Language.turkish.name, "Türkçe")
    }
}
