// 
//  See LICENSE.text for this project’s licensing information.
//
//  LogLevel.swift
//
//  Created by Bilal Durnagöl on 26.02.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// The actual implementation details. Implement this protocol if you want to really customize your logging
public protocol LogLevel {
  var rank: Int { get }
  var prefix: String { get }
}

internal extension LogLevel {

  var isLoggable: Bool {
    return backingLogger != nil || internalLogLevel.rank <= self.rank
  }

  func output(_ message: @autoclosure () -> Any, prefixedBy prefixes: [Any] = [], _ file: String, _ line: Int) {
    guard isLoggable else { return }
    let message = construct(message: message(), prefixedBy: prefixes, file, line)
    if let backingLogger = backingLogger {
      backingLogger.output(message: message, at: self)
      if backingLogger.logsToConsole {
        // we don't need to process locally
        return
      }
    }
    if internalLogLevel.rank <= self.rank {
      print(message)
    }
  }

  func build(prefixes: [Any] = [], _ file: String, _ line: Int) -> [Any] {
    if let fileName = file.components(separatedBy: "/").last?.components(separatedBy: ".").first {
      return ["\(fileName):\(line)"] + prefixes
    }
    return prefixes
  }

  func construct(message: @autoclosure () -> Any, prefixedBy prefixes: [Any], _ file: String, _ line: Int) -> Any {
    let prefixes = build(prefixes: prefixes, file, line)
    guard prefixes.count > 0 else {
      return message()
    }
    let customPrefix = prefixes.map { "[\($0)]" }.joined(separator: " ")
    return "\(prefix) \(customPrefix) \(message())"
  }
}
