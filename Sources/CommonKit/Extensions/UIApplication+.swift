// 
//  See LICENSE.text for this project’s licensing information.
//
//  UIApplication+.swift
//
//  Created by Bilal Durnagöl on 19.07.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(xrOS) || targetEnvironment(macCatalyst)
import UIKit
#elseif os(watchOS)
import UIKit
import WatchKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - iOS, xrOS, macCatalyst

#if os(iOS) || os(xrOS) || targetEnvironment(macCatalyst)

extension UIApplication {
    /// Opens the "Manage Subscriptions" page in the App Store application if possible.
    ///
    /// - Parameter completion: A closure called once the URL is opened or fails to open.
    /// - Important: This method attempts to open the system URL for managing subscriptions on iOS, xrOS, or macCatalyst.
    /// - Note: If the URL cannot be opened, `completion` is called with `false`.
    ///
    /// ### Example
    /// ```swift
    /// UIApplication.shared.openManageSubscriptions { success in
    ///     if success {
    ///         print("Successfully opened subscription management page.")
    ///     } else {
    ///         print("Could not open subscription management page.")
    ///     }
    /// }
    /// ```
    func openManageSubscriptions(completion: @escaping ((Bool) -> Void)) {
        if let url = URL(string: "https://apps.apple.com/account/subscriptions"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url) { isComplete in
                completion(isComplete)
            }
        } else {
            completion(false)
        }
    }
}

@available(iOS 13.0, tvOS 13.0, *)
extension UIApplication {
    /// Returns the first connected `UIWindowScene` for the application.
    ///
    /// This computed property looks at the `UIApplication.shared.connectedScenes`
    /// and tries to cast the first one to a `UIWindowScene`.
    ///
    /// - Returns: The first connected `UIWindowScene`, or `nil` if none is found.
    var windowsScene: UIWindowScene? {
        return UIApplication.shared.connectedScenes.first as? UIWindowScene
    }
}

#elseif os(watchOS)

// MARK: - watchOS

extension WKExtension {
    /// Opens the "Manage Subscriptions" page in the App Store application if possible.
    ///
    /// - Parameter completion: A closure that returns `true` if the system URL was opened, `false` otherwise.
    /// - Note: For watchOS, this method calls `WKExtension.shared().openSystemURL(_:)`.
    func openManageSubscriptions(completion: @escaping ((Bool) -> Void)) {
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            WKExtension.shared().openSystemURL(url)
            completion(true)
        } else {
            completion(false)
        }
    }
}

#elseif os(macOS)

// MARK: - macOS

extension NSApplication {
    /// Opens the "Manage Subscriptions" page in the default web browser if possible.
    ///
    /// - Parameter completion: A closure that indicates whether the URL was successfully opened.
    /// - Note: For macOS, this method uses `NSWorkspace.shared.open(_:)` to open the subscription link.
    func openManageSubscriptions(completion: @escaping ((Bool) -> Void)) {
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            let isOpen = NSWorkspace.shared.open(url)
            completion(isOpen)
        } else {
            completion(false)
        }
    }
}

#endif
