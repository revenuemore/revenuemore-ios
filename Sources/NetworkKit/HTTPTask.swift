// 
//  See LICENSE.text for this project’s licensing information.
//
//  HTTPTask.swift
//
//  Created by Bilal Durnagöl on 15.07.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// Represents an HTTP task.
enum HTTPTask {

    /// A request with no additional data.
    case requestPlain

    /// A requests body set with encoded parameters.
    case requestParameters(parameters: [String: Any], encoding: ParameterEncoding)

}
