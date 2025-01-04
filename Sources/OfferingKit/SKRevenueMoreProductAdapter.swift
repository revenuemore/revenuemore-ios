// 
//  See LICENSE.text for this project’s licensing information.
//
//  SKRevenueMoreProductAdapter.swift
//
//  Created by Bilal Durnagöl on 2.09.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

internal class SKRevenueMoreProductAdapter: @unchecked Sendable, RevenueMoreProductProtocol {

     let product: RM1Product
     
     init(product: RM1Product) {
         self.product = product
     }
    
    var description: String {
        return product.localizedDescription
    }
    
    var displayName: String {
        return product.localizedTitle
    }
    
    var currencyCode: String? {
        return product.priceLocale.currencyCode
    }
    
    var price: Decimal {
        return product.price as Decimal
    }
    
    var displayPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price) ?? ""
    }
    
    var id: String {
        return product.productIdentifier
    }
    
    @available(macOS 10.13.2, *)
    var period: RevenueMorePeriod? {
        if let subscriptionPeriod = product.subscriptionPeriod {
            return RevenueMorePeriod(subscriptionPeriod)
        } else {
            return nil
        }
    }
    
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
    var isFamilyShareable: Bool {
        return product.isFamilyShareable
    }
    
    @available(iOS 12.0, macCatalyst 13.0, tvOS 12.0, macOS 10.14, watchOS 6.2, *)
    var subscriptionGroupID: String? {
        return product.subscriptionGroupIdentifier
    }
    
    var priceFormatter: NumberFormatter? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter
    }
    
    var pricePerWeek: Decimal? {
        return period?.pricePerWeek(with: price)
    }
    
    var pricePerMonth: Decimal? {
        return period?.pricePerMonth(with: price)
    }
    
    var pricePerYear: Decimal? {
        return period?.pricePerYear(with: price)
    }
    
    var pricePerDay: Decimal? {
        return period?.pricePerDay(with: price)
    }
    
    var displayPricePerWeek: String? {
        priceFormatter?.string(for: pricePerWeek)
    }
    
    var displayPricePerMonth: String? {
        priceFormatter?.string(for: pricePerMonth)
    }
    
    var displayPricePerYear: String? {
        priceFormatter?.string(for: pricePerYear)
    }
    
    var displayPricePerDay: String? {
        priceFormatter?.string(for: pricePerDay)
    }
}
