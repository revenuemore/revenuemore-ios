// 
//  See LICENSE.text for this project’s licensing information.
//
//  Encodable+Tests.swift
//
//  Created by Bilal Durnagöl on 21.06.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import XCTest
@testable import RevenueMore

final class Encodable_Tests: XCTestCase {

    var mockModel: MockEncodable!
    var mockInvalidModel: MockInvalidEncodable!

    override func setUp() {
        super.setUp()
        mockModel = MockEncodable(id: 1, name: "Bilal", surname: "Durnagöl")
        mockInvalidModel = MockInvalidEncodable(invalidData: Data())
    }

    override func tearDown() {
        mockModel = nil
        mockInvalidModel = nil
        super.tearDown()
    }

    func testEncodable_WhenUseDictionaryMethod_ShouldReturnDictionary() {
        let dict = mockModel.dictionary
        let expectedDict: [String: Any] = ["id": 1, "name": "Bilal", "surname": "Durnagöl"]

        XCTAssertEqual(dict["id"] as? Int, expectedDict["id"] as? Int, "dict[id] should be equal expectedDict[id], but this isn't equal")
    }

    func testEncodable_WhenUseInvalidStruct_ShouldReturnEmptyDictionary() {
        let dict: [String: Any] = mockInvalidModel.dictionary

        XCTAssertTrue(dict.isEmpty, "dict.isEmpty should be true, but this isn't true")

    }

}
