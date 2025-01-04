// 
//  See LICENSE.text for this project’s licensing information.
//
//  RestoreClosure.swift
//
//  Created by Bilal Durnagöl on 20.09.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

internal typealias RestoreClosure = @Sendable (Result<[RevenueMorePaymentTransaction], RevenueMoreErrorInternal>) -> Void
