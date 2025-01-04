// 
//  See LICENSE.text for this project’s licensing information.
//
//  UnknownCaseRepresentableTests.swift
//
//  Created by Bilal Durnagöl on 28.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import XCTest

final class UnknownCaseRepresentableTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testKnownRawValueInitialization() {
        // Arrange
        let rawValue = "one"
        
        // Act
        let result = UnknownCaseRepresentableEnum(rawValue: rawValue)
        
        // Assert
        XCTAssertEqual(result, .one, "Known raw value should map to the correct enum case.")
    }
    
    func testUnknownRawValueInitialization() {
        // Arrange
        let rawValue = "unknownValue"
        
        // Act
        let result = UnknownCaseRepresentableEnum(rawValue: rawValue)
        
        // Assert
        XCTAssertEqual(result, .unknown, "Unknown raw value should map to the unknown case.")
    }
    
    func testAllCasesContainUnknownCase() {
        // Arrange
        let allCases = UnknownCaseRepresentableEnum.allCases
        
        // Assert
        XCTAssertTrue(allCases.contains(.unknown), "All cases should contain the unknown case.")
    }
    
    func testRawValueMappingConsistency() {
        // Arrange
        let testCases: [UnknownCaseRepresentableEnum: String] = [
            .one: "one",
            .two: "two",
            .three: "three",
            .unknown: "unknownValue" // No direct mapping, handled by unknown case
        ]
        
        // Act & Assert
        for (_, rawValue) in testCases {
            let mappedCase = UnknownCaseRepresentableEnum(rawValue: rawValue)
            if rawValue == "unknownValue" {
                XCTAssertEqual(mappedCase, .unknown, "Unknown value should map to unknown case.")
            } else {
                XCTAssertEqual(mappedCase.rawValue, rawValue, "Enum case raw value mapping is incorrect.")
            }
        }
    }
}
