// 
//  See LICENSE.text for this project’s licensing information.
//
//  RevenueMoreErrorInternalTests.swift
//
//  Created by Bilal Durnagöl on 21.06.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import XCTest
@testable import RevenueMore

import XCTest

final class RevenueMoreErrorInternalTests: XCTestCase {

    func testErrorDescription() {
        // Arrange
        let error = RevenueMoreErrorInternal.unexpected

        // Act
        let description = error.errorDescription

        // Assert
        XCTAssertEqual(description, Localizations.RevenueMoreError.Description.unexpected, "Error description should match the localization.")
    }

    func testFailureReason() {
        // Arrange
        let error = RevenueMoreErrorInternal.notFoundOffering

        // Act
        let reason = error.failureReason

        // Assert
        XCTAssertEqual(reason, Localizations.RevenueMoreError.Reason.notFoundOffering, "Failure reason should match the localization.")
    }

    func testRecoverySuggestion() {
        // Arrange
        let error = RevenueMoreErrorInternal.notFoundProduct

        // Act
        let suggestion = error.recoverySuggestion

        // Assert
        XCTAssertEqual(suggestion, Localizations.RevenueMoreError.RecoverySuggestion.notFoundProduct, "Recovery suggestion should match the localization.")
    }

    func testNSErrorConversion() {
        // Arrange
        let error = RevenueMoreErrorInternal.fetchPaywalls("Failed to fetch paywalls")

        // Act
        let nsError = error.convertPublicError

        // Assert
        XCTAssertEqual(nsError.domain, RevenueMoreErrorInternal.errorDomain, "NSError domain should match.")
        XCTAssertEqual(nsError.code, error.errorCode, "NSError code should match.")
        XCTAssertEqual(nsError.userInfo[NSLocalizedDescriptionKey] as? String, "Failed to fetch paywalls", "NSError description should match.")
    }

    func testCustomNSErrorConformance() {
        // Arrange
        let error = RevenueMoreErrorInternal.badURL

        // Act
        let domain = RevenueMoreErrorInternal.errorDomain
        let code = error.errorCode
        let userInfo = error.errorUserInfo

        // Assert
        XCTAssertEqual(domain, "RevenueMore", "Error domain should match the expected value.")
        XCTAssertEqual(code, 3004, "Error code for badURL should match.")
        XCTAssertTrue(userInfo.keys.contains(NSLocalizedDescriptionKey), "User info should contain a description.")
    }

    func testLocalizedErrorConformance() {
        // Arrange
        let error = RevenueMoreErrorInternal.invalidReceipt

        // Act
        let description = error.errorDescription
        let reason = error.failureReason
        let suggestion = error.recoverySuggestion

        // Assert
        XCTAssertEqual(description, Localizations.RevenueMoreError.Description.invalidReceipt, "Error description should match localization.")
        XCTAssertEqual(reason, Localizations.RevenueMoreError.Reason.invalidReceipt, "Failure reason should match localization.")
        XCTAssertEqual(suggestion, Localizations.RevenueMoreError.RecoverySuggestion.invalidReceipt, "Recovery suggestion should match localization.")
    }

    func testEquality() {
        // Arrange
        let error1 = RevenueMoreErrorInternal.notFoundProduct
        let error2 = RevenueMoreErrorInternal.notFoundProduct
        let error3 = RevenueMoreErrorInternal.unexpected

        // Act & Assert
        XCTAssertEqual(error1, error2, "Errors with the same type should be equal.")
        XCTAssertNotEqual(error1, error3, "Errors with different types should not be equal.")
    }

    func testCustomStringConvertible() {
        // Arrange
        let error = RevenueMoreErrorInternal.restorePaymentFailed("Restore failed due to network issue")

        // Act
        let description = error.description

        // Assert
        XCTAssertEqual(description, "Restore failed due to network issue", "Custom string description should match.")
    }

    func testDynamicCases() {
        // Arrange
        let fetchProductError = RevenueMoreErrorInternal.fetchProductFailed("Product fetch failed")
        let restoreError = RevenueMoreErrorInternal.restorePaymentFailed("Restore failed")

        // Act
        let fetchProductDescription = fetchProductError.description
        let restoreDescription = restoreError.description

        // Assert
        XCTAssertEqual(fetchProductDescription, "Product fetch failed", "Dynamic description for fetchProductFailed should match.")
        XCTAssertEqual(restoreDescription, "Restore failed", "Dynamic description for restorePaymentFailed should match.")
    }
}
