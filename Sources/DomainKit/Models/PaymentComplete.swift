// 
//  See LICENSE.text for this project’s licensing information.
//
//  PaymentComplate.swift
//
//  Created by Bilal Durnagöl on 7.07.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// An enumeration grouping types related to completing a payment.
///
/// The `PaymentComplete` namespace includes request and response types
/// (`Request` and `Response`) used when finalizing or verifying a payment.
enum PaymentComplete {
    
    /// A request model for completing a payment, containing receipt data.
    ///
    /// Conforms to `Encodable` so it can be serialized and sent in a
    /// network request. The `receiptData` property is encoded using
    /// `"rd"` as its key in JSON.
    struct Request: Encodable {
        
        /// The Base64-encoded receipt data string required for payment completion.
        ///
        /// - Note: This property is mapped to `"rd"` in the JSON payload
        ///   (see the `CodingKeys` enum).
        let receiptData: String
        /// Transaction id string required for payment completion.
        ///
        /// - Note: This property is mapped to `"ti"` in the JSON payload
        ///   (see the `CodingKeys` enum).
        let transactionIdentifier: String?

        /// Coding keys used to map the `receiptData` property to `"rd"` in the JSON payload.
        /// /// Coding keys used to map the `transactionIdentifier` property to `"ti"` in the JSON payload.
        enum CodingKeys: String, CodingKey {
            case receiptData = "rd"
            case transactionIdentifier = "ti"
        }
    }

    /// An empty response model for payment completion requests.
    ///
    /// Conforms to `Decodable` to support JSON decoding of any returned data,
    /// though the struct currently has no properties.
    struct Response: Decodable { }
}
