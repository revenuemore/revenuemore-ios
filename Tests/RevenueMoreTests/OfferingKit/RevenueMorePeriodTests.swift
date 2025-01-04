// 
//  See LICENSE.text for this project’s licensing information.
//
//  RevenueMorePeriodTests.swift
//
//  Created by Bilal Durnagöl on 11.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import XCTest
@testable import RevenueMore

final class RevenueMorePeriodTests: XCTestCase {
    
    func testDayCount() {
        XCTAssertEqual(RevenueMorePeriod(value: 1, unit: .day).dayCount, 1)
        XCTAssertEqual(RevenueMorePeriod(value: 1, unit: .week).dayCount, 7)
        XCTAssertEqual(RevenueMorePeriod(value: 1, unit: .month).dayCount, 30)
        XCTAssertEqual(RevenueMorePeriod(value: 1, unit: .year).dayCount, 365)
        XCTAssertEqual(RevenueMorePeriod(value: 1, unit: .unknown).dayCount, 0)
    }
    
    func testPricePerDay() {
        let period = RevenueMorePeriod(value: 7, unit: .week) // 7 weeks = 49 days
        let price = Decimal(49.00) // $49 total price
        XCTAssertEqual(period.pricePerDay(with: price), Decimal(1.00)) // $1 per day
    }
    
    func testPricePerWeek() {
        let period = RevenueMorePeriod(value: 4, unit: .month) // 4 months = 120 days
        let price = Decimal(120.00) // $120 total price
        XCTAssertEqual(period.pricePerWeek(with: price), Decimal(7.00)) // $7 per week
    }
    
    func testPricePerMonth() {
        let period = RevenueMorePeriod(value: 6, unit: .month) // 6 months = 180 days
        let price = Decimal(365.00) // $365 total price
        XCTAssertEqual(period.pricePerMonth(with: price), 60.83) // $60.83 per month
    }
    
    func testPricePerYear() {
        let period = RevenueMorePeriod(value: 2, unit: .year) // 2 years = 730 days
        let price = Decimal(730.00) // $730 total price
        XCTAssertEqual(period.pricePerYear(with: price), Decimal(365.00)) // $365 per year
    }
    
    func testRoundingPrice() {
        let period = RevenueMorePeriod(value: 1, unit: .month)
        let roundedPrice = period.roundingPrice(with: Decimal(10.5678), by: Decimal(1))
        XCTAssertEqual(roundedPrice, Decimal(10.56)) // Rounded down to 2 decimal places
    }
}
