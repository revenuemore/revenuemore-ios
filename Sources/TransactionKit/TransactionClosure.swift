// 
//  See LICENSE.text for this project’s licensing information.
//
//  TransactionClosure.swift
//
//  Created by Bilal Durnagöl on 16.09.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

internal typealias TransactionClosure = @Sendable (Result<RevenueMorePaymentTransaction, RevenueMoreErrorInternal>) -> Void
