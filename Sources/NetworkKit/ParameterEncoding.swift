// 
//  See LICENSE.text for this project’s licensing information.
//
//  ParameterEncoding.swift
//
//  Created by Bilal Durnagöl on 15.07.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// A dictionary of parameters to apply to a `URLRequest`.
public typealias Parameters = [String: Any]

/// A type used to define how a set of parameters are applied to a `URLRequest`.
enum ParameterEncoding {
    ///
    case httpBody
    case query
}
