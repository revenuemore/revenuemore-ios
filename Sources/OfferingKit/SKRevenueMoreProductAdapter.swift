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
        #if os(visionOS)
        return product.priceLocale.currency?.identifier
        #elseif os(watchOS)
        return product.priceLocale.currency?.identifier
        #else
        return product.priceLocale.currencyCode
        #endif
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
    
    @available(macOS 10.13.2, *)
    var pricePerWeek: Decimal? {
        return period?.pricePerWeek(with: price)
    }
    
    @available(macOS 10.13.2, *)
    var pricePerMonth: Decimal? {
        return period?.pricePerMonth(with: price)
    }
    
    @available(macOS 10.13.2, *)
    var pricePerYear: Decimal? {
        return period?.pricePerYear(with: price)
    }
    
    @available(macOS 10.13.2, *)
    var pricePerDay: Decimal? {
        return period?.pricePerDay(with: price)
    }
    
    @available(macOS 10.13.2, *)
    var displayPricePerWeek: String? {
        priceFormatter?.string(for: pricePerWeek)
    }
    
    @available(macOS 10.13.2, *)
    var displayPricePerMonth: String? {
        priceFormatter?.string(for: pricePerMonth)
    }
    
    @available(macOS 10.13.2, *)
    var displayPricePerYear: String? {
        priceFormatter?.string(for: pricePerYear)
    }
    
    @available(macOS 10.13.2, *)
    var displayPricePerDay: String? {
        priceFormatter?.string(for: pricePerDay)
    }
}
