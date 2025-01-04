// 
//  See LICENSE.text for this project’s licensing information.
//
//  Log.swift
//
//  Created by Bilal Durnagöl on 26.02.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

// logLevel allows you to specify the minimum log level to display messages for.
// Example:  setting logLevel to .warn will allow .warn and .error log
// messages to display and prevent .debug and .info messages from displaying.
// It can be updated in the debugger by typing `expr logLevel = Log.trace`
internal var internalLogLevel: LogLevel = {
    #if DEBUG
    return Log.trace
    #else
    return Log.info
    #endif
}()

// MARK: Implementation details

/** Typcial Logging levels
 - 📋 trace: trace logging level
 - 🐛 debug: debug logging level
 - 🗣 info: info logging level
 - 💥 warn: warn logging level
 - 💩 error: error logging level
 - custom: a way to add your own custom logging level without needing to add new cases to this enum
 */
public enum Log: LogLevel {

    case trace
    case debug
    case info
    case warn
    case error
    case apple
    case custom(rank: Int, prefix: String)

    public var rank: Int {
        switch self {
        case .trace: return 0
        case .debug: return 1
        case .info: return 2
        case .warn: return 3
        case .error: return 4
        case .apple: return 5
        case .custom(let customRank, _): return customRank
        }
    }

    public var prefix: String {
        switch self {
        case .trace: return "📋  [TRACE]"
        case .debug: return "🐛  [DEBUG]"
        case .info:  return "🗣  [INFO] "
        case .warn:  return "💥💥[WARN] "
        case .error: return "💩💩[ERROR]"
        case .apple: return "🍎🍎[APPLE]"
        case .custom(_, let customPrefix): return customPrefix
        }
    }
}
