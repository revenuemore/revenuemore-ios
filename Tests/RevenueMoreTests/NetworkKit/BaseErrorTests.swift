// 
//  See LICENSE.text for this project’s licensing information.
//
//  BaseErrorTests.swift
//
//  Created by Bilal Durnagöl on 21.06.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import XCTest
@testable import RevenueMore

final class BaseErrorTests: XCTestCase {

    func testsBaseError_ShouldReturnCustomMessage() {
        var error: BaseError
        var message: String = ""

        // Decode
        error = .decode
        message = "Decode error"
        XCTAssertEqual(error.customMessage, message, "It's need to equal customMessage to message, but it isn't equal")

        // unauthorized
        error = .unauthorized
        message = "Session expired"
        XCTAssertEqual(error.customMessage, message, "It's need to equal customMessage to message, but it isn't equal")

        // custom isn't nil
        error = .custom(error: "This is error")
        message = "This is error"
        XCTAssertEqual(error.customMessage, message, "It's need to equal customMessage to message, but it isn't equal")

        // custom is nil
        error = .custom(error: nil)
        message = "Unknown error"
        XCTAssertEqual(error.customMessage, message, "It's need to equal customMessage to message, but it isn't equal")

        // other

        error = .unknown
        message = "Unknown error"
        XCTAssertEqual(error.customMessage, message, "It's need to equal customMessage to message, but it isn't equal")

    }

}
