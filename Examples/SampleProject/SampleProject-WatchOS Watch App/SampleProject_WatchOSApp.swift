// 
//  See LICENSE.text for this project’s licensing information.
//
//  SampleProject_WatchOSApp.swift
//  SampleProject-WatchOS Watch App
//
//  Created by Bilal Durnagöl on 24.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import SwiftUI
import RevenueMore

@main
struct SampleProject_WatchOS_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
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
