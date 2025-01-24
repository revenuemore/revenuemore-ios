// 
//  See LICENSE.text for this project’s licensing information.
//
//  StoreKit2PurchaseTests.swift
//
//  Created by Bilal Durnagöl on 29.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import XCTest
import StoreKitTest
@testable import RevenueMore

@available(iOS 15.0, tvOS 15.0, macOS 12.0, *)
final class StoreKit2PurchaseTests: XCTestCase {

    // MARK: - Properties
    
    private var testSession: SKTestSession!
    private var sut: StoreKit2Purchase!
    
    
    override func setUp() async throws  {
        if self.testSession == nil {
            try await self.configureTestSession()
        }
        sut = StoreKit2Purchase(forceFinishTransaction: true)
        try await super.setUp()
    }
    
    override func tearDown() async throws {
        if let testSession = self.testSession {
            testSession.clearTransactions()
        }
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
}
