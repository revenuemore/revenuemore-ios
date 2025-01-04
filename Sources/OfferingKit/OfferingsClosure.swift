// 
//  See LICENSE.text for this project’s licensing information.
//
//  OfferingsClosure.swift
//
//  Created by Bilal Durnagöl on 7.09.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

typealias OfferingsClosure = @Sendable (Result<Offerings, RevenueMoreErrorInternal>) -> Void
