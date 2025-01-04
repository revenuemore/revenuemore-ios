// 
//  See LICENSE.text for this project’s licensing information.
//
//  SampleProject_VisionOSApp.swift
//  SampleProject-VisionOS
//
//  Created by Bilal Durnagöl on 24.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import SwiftUI
import RevenueMore

@main
struct SampleProject_VisionOSApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    RevenueMore.start(
                        apiKey: "xxx-yyy-zzz",
                        userId: "rm_test_user_ios",
                        forceFinishTransaction: false,
                        language: .english
                    )
                }
        }
    }
}
