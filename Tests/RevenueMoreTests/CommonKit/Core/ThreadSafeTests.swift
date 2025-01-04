// 
//  See LICENSE.text for this project’s licensing information.
//
//  ThreadSafetyTests.swift
//
//  Created by Bilal Durnagöl on 14.03.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import XCTest
@testable import RevenueMore

final class ThreadSafeTests: XCTestCase {

    var counter: ThreadSafe<Int>?

    override func setUp() {
        counter = .init(0)
    }

    override func tearDown() {
        counter = nil
    }

    func testThreadSafe_WhenUseTheadSafeWithLoop_ShouldBeEqual() {
        DispatchQueue.concurrentPerform(iterations: 10) { _ in
          for _ in 0 ..< 1_000 {
              counter?.modify { newValue in
                  newValue += 1
              }
          }

        }
        XCTAssertEqual(counter?.value ?? 0, 1_000_0, "Counter should be equal 1_0000_00, but this counter isn't equal")
    }
}
