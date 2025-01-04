// 
//  See LICENSE.text for this project’s licensing information.
//
//  SampleProject_WatchOS_Watch_AppUITestsLaunchTests.swift
//  SampleProject-WatchOS Watch AppUITests
//
//  Created by Bilal Durnagöl on 24.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import XCTest

final class SampleProject_WatchOS_Watch_AppUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
