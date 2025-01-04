// 
//  See LICENSE.text for this project’s licensing information.
//
//  PurchaseClosure.swift
//
//  Created by Bilal Durnagöl on 11.09.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

internal typealias PurchaseClosure = @Sendable (Result<RevenueMorePaymentTransaction, RevenueMoreErrorInternal>) -> Void
public typealias PublicPurchaseClosure = @Sendable (Result<RevenueMorePaymentTransaction, RevenueMoreError>) -> Void
