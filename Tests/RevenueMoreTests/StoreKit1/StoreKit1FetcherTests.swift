//
//  See LICENSE.text for this project’s licensing information.
//
//  StoreKit1FetcherTests.swift
//
//  Created by Bilal Durnagöl on 21.06.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import XCTest
@testable import RevenueMore
import StoreKitTest

class MockProductsRequest: ProductsRequestProtocol {
    weak var delegate: SKProductsRequestDelegate?
    private(set) var startCalled = false
    var mockResponse: SKProductsResponse?
    
    func start() {
        startCalled = true
        if let response = mockResponse {
            delegate?.productsRequest(SKProductsRequest(), didReceive: response)
        }
    }
}

class MockProductRequestCreator: ProductRequestCreating {
    let mockRequest: MockProductsRequest
    
    init(mockRequest: MockProductsRequest) {
        self.mockRequest = mockRequest
    }
    
    func createRequest(productIdentifiers: Set<String>) -> ProductsRequestProtocol {
        return mockRequest
    }
}

@available(iOS 15.0, *)
final class StoreKit1FetcherTests: XCTestCase {
    
    private var testSession: SKTestSession!
    private var sut: StoreKit1Fetcher!
    private var mockRequest: MockProductsRequest!
    private var mockRequestCreator: MockProductRequestCreator!
    
    override func setUp() async throws {
        if self.testSession == nil {
            try await self.configureTestSession()
        }
        mockRequest = MockProductsRequest()
        mockRequestCreator = MockProductRequestCreator(mockRequest: mockRequest)
        sut = StoreKit1Fetcher(
            queue: .main,
            requestCreator: mockRequestCreator
        )
        try await super.setUp()
    }
    
    override func tearDown() async throws {
        if let testSession = self.testSession {
            testSession.clearTransactions()
        }
        
        mockRequest = nil
        mockRequestCreator = nil
        sut = nil
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
    
    func testFetchProducts_WithEmptyIds_ReturnsError() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch products")
        
        // When
        sut.fetchProducts(with: []) { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertEqual(error, .notFoundProductIDs)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
