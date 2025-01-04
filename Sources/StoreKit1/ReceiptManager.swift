// 
//  See LICENSE.text for this project’s licensing information.
//
//  ReceiptManager.swift
//
//  Created by Bilal Durnagöl on 12.07.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

class ReceiptManager {

    // Get the receipt if it's available.
    func generateReceiptString(completion: @escaping (Result<String, RevenueMoreErrorInternal>) -> Void) {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
           FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)

                let receiptString = receiptData.base64EncodedString(options: [])
                // Read receiptData.
                completion(.success(receiptString))
            } catch {
                🍎("Receipt data not found.")
                completion(.failure(.invalidReceipt))
            }
        } else {
            🍎("Receipt data not found.")
            completion(.failure(.invalidReceipt))
        }
    }

    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    func generateReceiptString() async throws -> String? {
        return try await withCheckedThrowingContinuation { continuation in
            generateReceiptString { receipt in
                continuation.resume(with: receipt)
            }
        }
    }

}

// Non-final class 'ReceiptManager' cannot conform to 'Sendable'; use '@unchecked Sendable'
extension ReceiptManager: @unchecked Sendable { }
