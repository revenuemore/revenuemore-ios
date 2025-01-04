// 
//  See LICENSE.text for this project’s licensing information.
//
//  OfferingTrigger.swift
//
//  Created by Bilal Durnagöl on 3.09.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

public struct OfferingTrigger {
    
    public let identifier: String
    
    public let offering: Offering?
    
    public let isCurrent: Bool
    
    public init(identifier: String, offering: Offering?, isCurrent: Bool) {
        self.identifier = identifier
        self.offering = offering
        self.isCurrent = isCurrent
    }
}
