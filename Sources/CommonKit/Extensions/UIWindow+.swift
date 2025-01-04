// 
//  See LICENSE.text for this project’s licensing information.
//
//  UIWindow+.swift
//
//  Created by Bilal Durnagöl on 18.07.2024.
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

// MARK: - iOS / tvOS / macCatalyst / xrOS

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst) || os(xrOS)

/// An extension adding a sort priority to each UIScene.ActivationState.
///
/// For example, `.foregroundActive` has the highest priority (1), and `.unattached` has the lowest (4).
/// This property is used to sort scenes by their activation state, ensuring that
/// the most relevant (`foregroundActive`) scenes appear first in a sorted collection.
@available(iOS 13.0, tvOS 13.0, *)
private extension UIScene.ActivationState {
    /// An integer that represents the priority of the scene's activation state.
    ///
    /// Lower numbers signify higher priority:
    /// - `.foregroundActive` → 1
    /// - `.foregroundInactive` → 2
    /// - `.background` → 3
    /// - `.unattached` → 4
    ///
    /// - Returns: An `Int` value indicating the scene’s priority.
    var sortPriority: Int {
        switch self {
        case .foregroundActive: return 1
        case .foregroundInactive: return 2
        case .background: return 3
        case .unattached: return 4
        @unknown default: return 5
        }
    }
}

#elseif os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

// MARK: - iOS / tvOS / macCatalyst (Older Clause)

extension UIWindow {
    /// Finds and returns the key window for the app on iOS/tvOS/macCatalyst.
    ///
    /// - If running on iOS 13.0 or tvOS 13.0 or later, this property sorts the app’s connected scenes by their
    ///   `activationState.sortPriority` (determined above), then returns the first window marked as `.isKeyWindow`.
    /// - Otherwise, it falls back to `UIApplication.shared.keyWindow`.
    ///
    /// - Returns: The current key `UIWindow`, or `nil` if none is available.
    static var keyWindow: UIWindow? {
        if #available(iOS 13.0, tvOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .sorted { $0.activationState.sortPriority < $1.activationState.sortPriority }
                .compactMap { $0 as? UIWindowScene }
                .compactMap { $0.windows.first { $0.isKeyWindow } }
                .first
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}

#elseif os(xrOS)

// MARK: - xrOS

extension UIWindow {
    
    /// Finds and returns the key window for the app on xrOS.
    ///
    /// - If running on iOS 13.0 or tvOS 13.0 or later (for xrOS), this property sorts the app’s connected scenes
    ///   by `activationState.sortPriority` and returns the first window marked as `.isKeyWindow`.
    /// - Otherwise, it falls back to `UIWindow.activeWindow`.
    ///
    /// - Returns: The current key `UIWindow`, or `nil` if none is available.
    static var keyWindow: UIWindow? {
        if #available(iOS 13.0, tvOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .sorted { $0.activationState.sortPriority < $1.activationState.sortPriority }
                .compactMap { $0 as? UIWindowScene }
                .compactMap { $0.windows.first { $0.isKeyWindow } }
                .first
        } else {
            return UIWindow.activeWindow
        }
    }
    
    /// Returns the first active `UIWindowScene` that’s currently in the foreground.
    ///
    /// - Returns: A `UIWindowScene` in the `.foregroundActive` state, or `nil` if no such scene is found.
    static var activeWindowScene: UIWindowScene? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
    }

    /// Returns the key window within the first active `UIWindowScene`.
    ///
    /// - Note: This is a convenience property that looks up the `activeWindowScene` first,
    ///   then returns its first `.isKeyWindow`.
    /// - Returns: The key `UIWindow` within the active window scene, or `nil` if none is found.
    static var activeWindow: UIWindow? {
        return activeWindowScene?.windows.first { $0.isKeyWindow }
    }
}

#elseif os(macOS)

// MARK: - macOS

extension NSWindow {
    /// Finds and returns the key window for the current macOS application.
    ///
    /// It first attempts to retrieve `NSApplication.shared.keyWindow`. If that’s `nil`,
    /// it then falls back to `NSApplication.shared.mainWindow`.
    ///
    /// - Returns: The current key `NSWindow`, or `nil` if no window is key or main.
    static var keyWindow: NSWindow? {
        return NSApplication.shared.keyWindow ?? NSApplication.shared.mainWindow
    }
}

#endif
