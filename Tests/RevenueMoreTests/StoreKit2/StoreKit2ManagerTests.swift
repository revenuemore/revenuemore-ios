// 
//  See LICENSE.text for this project’s licensing information.
//
//  StoreKit2ManagerTests.swift
//
//  Created by Bilal Durnagöl on 21.06.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import XCTest
@testable import RevenueMore

@available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
final class StoreKit2ManagerTests: XCTestCase {

    // MARK: - PROPERTIES

    var storeKit2Manager: StoreKit2Manager!

    override func setUp() {
        super.setUp()
        
        storeKit2Manager = StoreKit2Manager(
            userManager: UserManager(
            userCache: UserCache()), 
            storeKit2Fetcher: StoreKit2Fetcher(),
            storeKit2Purchase: StoreKit2Purchase(forceFinishTransaction: true)
        )
    }

    override func tearDown() {
        storeKit2Manager = nil
        super.tearDown()
    }

    func testFetchProducts() async throws {
        let productIds: Set<String> = Set(["6m_rm_access", "1m_rm_access"])
        do {
           let products = try await storeKit2Manager.fetchProducts(with: productIds)
            XCTAssertEqual(products.count, productIds.count, "Counts should be equal, but it isn't.")
        } catch let error as RevenueMoreError {
            XCTFail("Unexpected error: \(error)")
        }
    }

}
