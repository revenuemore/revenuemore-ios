// 
//  See LICENSE.text for this project’s licensing information.
//
//  MockStoreKit1Fetcher.swift
//
//  Created by Bilal Durnagöl on 15.12.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation
@testable import RevenueMore

class MockStoreKit1Fetcher: StoreKit1FetcherProtocol {
    // MARK: - Call Tracking
    private(set) var fetchProductsCalls: [Set<String>] = []
    
    // MARK: - Mock Control
    var mockResult: Result<[RM1Product], RevenueMoreErrorInternal>?
    var mockDelay: TimeInterval = 0
    
    func fetchProducts(
        with ids: Set<String>,
        completion: @escaping @Sendable (Result<[RM1Product], RevenueMoreErrorInternal>) -> Void
    ) {
        fetchProductsCalls.append(ids)
        
        guard let mockResult = mockResult else { return }
        
        if mockDelay > 0 {
            DispatchQueue.global().asyncAfter(deadline: .now() + mockDelay) {
                completion(mockResult)
            }
        } else {
            completion(mockResult)
        }
    }
    
    func reset() {
        fetchProductsCalls.removeAll()
        mockResult = nil
        mockDelay = 0
    }
}
