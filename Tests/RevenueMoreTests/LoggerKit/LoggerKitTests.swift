// 
//  See LICENSE.text for this project’s licensing information.
//
//  LoggerKitTests.swift
//
//  Created by Bilal Durnagöl on 26.02.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import XCTest
@testable import RevenueMore

final class LoggerKitTests: XCTestCase {

    func testLogger_WhenLogLevelRankHigh_LowShouldReturnFalse() {
        internalLogLevel = Log.debug
        let level = Log.trace

        XCTAssertFalse(level.isLoggable, "It's need to return false when level rank lower than the other rank but It's return true")
    }

    func testLogger_WhenLogLevelRankLow_LowShouldReturnTrue() {
        internalLogLevel = Log.debug
        let level = Log.apple

        XCTAssertTrue(level.isLoggable, "It's need to return true when level rank higher than the other rank but It's return false")
    }

    func testLogger_WhenLogLevelRankLowInfo_LowShouldReturnTrue() {
        internalLogLevel = Log.debug
        let level = Log.info

        XCTAssertTrue(level.isLoggable, "It's need to return true when level rank higher than the other rank but It's return false")
    }

    func testLogger_WhenLogLevelRankLowWarn_LowShouldReturnTrue() {
        internalLogLevel = Log.debug
        let level = Log.warn

        XCTAssertTrue(level.isLoggable, "It's need to return true when level rank higher than the other rank but It's return false")
    }

    func testLogger_WhenLogLevelRankLowError_LowShouldReturnTrue() {
        internalLogLevel = Log.debug
        let level = Log.error

        XCTAssertTrue(level.isLoggable, "It's need to return true when level rank higher than the other rank but It's return false")
    }

    func testLogger_WhenLogLevelRankLowCustom_LowShouldReturnTrue() {
        internalLogLevel = Log.debug
        let level = Log.custom(rank: 17, prefix: "custom")

        XCTAssertTrue(level.isLoggable, "It's need to return true when level rank higher than the other rank but It's return false")
    }

    func testLogger_WhenPrefixTrace_ShouldReturnStringPrefix() {
        let prefix = Log.trace.prefix
        XCTAssertEqual(prefix, "📋  [TRACE]", "It's need to return prefix, but it's not return")
    }

    func testLogger_WhenPrefixDebug_ShouldReturnStringPrefix() {
        let prefix = Log.debug.prefix
        XCTAssertEqual(prefix, "🐛  [DEBUG]", "It's need to return prefix, but it's not return")
    }

    func testLogger_WhenPrefixInfo_ShouldReturnStringPrefix() {
        let prefix = Log.info.prefix
        XCTAssertEqual(prefix, "🗣  [INFO] ", "It's need to return prefix, but it's not return")
    }

    func testLogger_WhenPrefixWarn_ShouldReturnStringPrefix() {
        let prefix = Log.warn.prefix
        XCTAssertEqual(prefix, "💥💥[WARN] ", "It's need to return prefix, but it's not return")
    }

    func testLogger_WhenPrefixError_ShouldReturnStringPrefix() {
        let prefix = Log.error.prefix
        XCTAssertEqual(prefix, "💩💩[ERROR]", "It's need to return prefix, but it's not return")
    }

    func testLogger_WhenPrefixApple_ShouldReturnStringPrefix() {
        let prefix = Log.apple.prefix
        XCTAssertEqual(prefix, "🍎🍎[APPLE]", "It's need to return prefix, but it's not return")
    }

    func testLogger_WhenPrefixCustom_ShouldReturnStringPrefix() {
        let prefix = Log.custom(rank: 1, prefix: "customPrefix").prefix
        XCTAssertEqual(prefix, "customPrefix", "It's need to return prefix, but it's not return")
    }

}
