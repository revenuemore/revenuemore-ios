// 
//  See LICENSE.text for this project’s licensing information.
//
//  AppDelegate.swift
//
//  SampleProject-MacOS
//
//  Created by Bilal Durnagöl on 20.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Cocoa
import RevenueMore

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var window: NSWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window = NSWindow(contentRect: NSMakeRect(0, 0, NSScreen.main?.frame.width ?? 100, NSScreen.main?.frame.height ?? 100), // for full height and width of screen
        styleMask: [.miniaturizable, .closable, .resizable, .titled],
        backing: .buffered,
        defer: false)
        
        RevenueMore.start(
            apiKey: "xxx-yyy-zzz",
            userId: "rm_test_user_ios",
            forceFinishTransaction: false,
            language: .english
        )
        window?.title = "Revenue More"
        window?.contentViewController = MainViewController()
        window?.makeKeyAndOrderFront(nil)
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

