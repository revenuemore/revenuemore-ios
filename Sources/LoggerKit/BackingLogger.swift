// 
//  See LICENSE.text for this project’s licensing information.
//
//  BackingLogger.swift
//
//  Created by Bilal Durnagöl on 26.02.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

internal protocol BackingLogger {
  // whether or not to use the backing logger for console logging or if EmojiLogger should handle console logging
  var logsToConsole: Bool { get }
  func output(message: Any, at level: LogLevel)
}

internal var backingLogger: BackingLogger?
