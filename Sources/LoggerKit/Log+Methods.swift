// 
//  See LICENSE.text for this project’s licensing information.
//
//  Log+Methods.swift
//
//  Created by Bilal Durnagöl on 26.02.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation
// swiftlint:disable identifier_name
/** trace logging
 - Parameter message: The message you want to log
 - Parameter prefixes: optional items that will be wrapped in square brackets in front of your message
 
 ```
 📋("my message")
 ```
 > 📋 [TRACE] [MyClass:lineNumber] my message
 */
internal func 📋(_ message: @autoclosure () -> Any = #function, prefixedBy prefixes: [Any] = [], _ file: String = #file, _ line: Int = #line) {
  Log.trace.output(message(), prefixedBy: prefixes, file, line)
}

/** debug logging
 - Parameter message: The message you want to log
 - Parameter prefixes: optional items that will be wrapped in square brackets in front of your message
 
 🐛("my message")
 > 🐛 [DEBUG] [MyClass:lineNumber] my message
 */
internal func 🐛(_ message: @autoclosure () -> Any, prefixedBy prefixes: [Any] = [], _ file: String = #file, _ line: Int = #line) {
  Log.debug.output(message(), prefixedBy: prefixes, file, line)
}

/** info logging
 - Parameter message: The message you want to log
 - Parameter prefixes: optional items that will be wrapped in square brackets in front of your message
 
 🗣("my message")
 > 🗣 [INFO] [MyClass:lineNumber] my message
 */
internal func 🗣(_ message: @autoclosure () -> Any, prefixedBy prefixes: [Any] = [], _ file: String = #file, _ line: Int = #line) {
  Log.info.output(message(), prefixedBy: prefixes, file, line)
}

/** warn logging
 - Parameter message: The message you want to log
 - Parameter prefixes: optional items that will be wrapped in square brackets in front of your message
 
 💥("my message")
 > 💥💥[WARN] [MyClass:lineNumber] my message
 */
internal func 💥(_ message: @autoclosure () -> Any, prefixedBy prefixes: [Any] = [], _ file: String = #file, _ line: Int = #line) {
  Log.warn.output(message(), prefixedBy: prefixes, file, line)
}

/** error logging
 - Parameter message: The message you want to log
 - Parameter prefixes: optional items that will be wrapped in square brackets in front of your message
 
 💩("my message")
 > 💩💩[ERROR] [MyClass:lineNumber] my message
 */
internal func 💩(_ message: @autoclosure () -> Any, prefixedBy prefixes: [Any] = [], _ file: String = #file, _ line: Int = #line) {
  Log.error.output(message(), prefixedBy: prefixes, file, line)
}

/** error logging
 - Parameter message: The message you want to log
 - Parameter prefixes: optional items that will be wrapped in square brackets in front of your message
 
 🍎("my message")
 > 🍎🍎[APPLE] [MyClass:lineNumber] my message
 */
internal func 🍎(_ message: @autoclosure () -> Any, prefixedBy prefixes: [Any] = [], _ file: String = #file, _ line: Int = #line) {
  Log.apple.output(message(), prefixedBy: prefixes, file, line)
}
// swiftlint:enable identifier_name
