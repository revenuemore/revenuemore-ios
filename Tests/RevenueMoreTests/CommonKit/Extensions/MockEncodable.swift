// 
//  See LICENSE.text for this project’s licensing information.
//
//  MockEncodable.swift
//
//  Created by Bilal Durnagöl on 21.06.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

struct MockEncodable: Encodable {
    var id: Int
    var name: String
    var surname: String
}

struct MockInvalidEncodable: Encodable {
    let invalidData: Any

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode("invalidData") // intentionally cause failure by encoding an invalid value
    }
}
