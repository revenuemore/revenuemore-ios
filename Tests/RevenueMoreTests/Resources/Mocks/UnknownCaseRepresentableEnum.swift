// 
//  See LICENSE.text for this project’s licensing information.
//
//  UnknownCaseRepresentableEnum.swift
//
//  Created by Bilal Durnagöl on 28.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import RevenueMore

enum UnknownCaseRepresentableEnum: String, UnknownCaseRepresentable {
    case one = "one"
    case two = "two"
    case three = "three"
    case unknown
    
    static var unknownCase: Self {
        return .unknown
    }
}
