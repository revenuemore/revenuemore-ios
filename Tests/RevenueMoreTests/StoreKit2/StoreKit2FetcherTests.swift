// 
//  See LICENSE.text for this project’s licensing information.
//
//  StoreKit2FetcherTests.swift
//
//  Created by Bilal Durnagöl on 21.06.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import XCTest
@testable import RevenueMore
import StoreKitTest

@available(iOS 15.0, tvOS 15.0, macOS 12.0, *)
final class StoreKit2FetcherTests: XCTestCase {

    // MARK: - PROPERTIES

    private var testSession: SKTestSession!
    private var sut: StoreKit2Fetcher!

    override func setUp() async throws {
        sut = StoreKit2Fetcher()
        if self.testSession == nil {
            try await self.configureTestSession()
        }
        try await super.setUp()
    }

    override func tearDown() async throws {
        sut = nil
        if let testSession = self.testSession {
            testSession.clearTransactions()
        }

        try await super.tearDown()
    }

    func configureTestSession() async throws {
        assert(self.testSession == nil, "Attempted to configure session multiple times")

        if let url = Bundle.module.url(forResource: "StoreConfiguration", withExtension: "storekit") {
            self.testSession = try SKTestSession(contentsOf: url)
        }

        self.testSession.resetToDefaultState()
        self.testSession.disableDialogs = true
        self.testSession.clearTransactions()
    }

    func testStoreKit2Fetcher_WhenProductIdIsNilFetchProduct_ShouldReturnError() async throws {
        do {
          _ = try await sut.fetchProducts(with: [])
            XCTFail("Expected failure, but got success")
        } catch let error as RevenueMoreErrorInternal {
            XCTAssertEqual(error, RevenueMoreErrorInternal.notFoundProductIDs, "Error should be equal to notFoundProductId, but it is not.")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testStoreKit2Fetcher_WhenSetProductId_FetchProductReturnProducts() async throws {
        let productIds: Set<String> = Set(["6m_rm_access", "1m_rm_access"])
        do {
          let products = try await sut.fetchProducts(with: productIds)
            XCTAssertEqual(products.count, productIds.count, "Counts should be equal, but it isn't.")

        } catch let error as RevenueMoreError {
            XCTFail("Expected failure \(error)")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testStoreKit2Fetcher_WhenSetInvalidProductId_FetchProductReturnError() async throws {
        let productIds: Set<String> = Set(["6m_rm_access_invalid", "1m_rm_access_invalid"])
        do {
          let products = try await sut.fetchProducts(with: productIds)
            XCTAssertTrue(products.isEmpty, "this should be nil, but it isn't")

        } catch let error as RevenueMoreErrorInternal {
            XCTAssertEqual(error, RevenueMoreErrorInternal.notFoundStoreProduct)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
