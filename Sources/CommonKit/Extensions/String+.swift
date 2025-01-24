// 
//  See LICENSE.text for this project’s licensing information.
//
//  String+.swift
//
//  Created by Bilal Durnagöl on 22.10.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// An extension that provides a localized version of a `String` based on the user's preferred language settings.
///
/// This extension reads the user's language code from `UserDefaults` (using the key from `UserCacheStorage.languageCode`),
/// then looks up a corresponding `.lproj` file in the module’s bundle. If no matching `.lproj` is found,
/// the logic falls back to English (`"en"`) or ultimately to the module's default localization.
extension String {
    
    /// A localized version of the current string.
    ///
    /// This computed property checks the user’s language preference from `UserDefaults`,
    /// attempts to load the appropriate bundle resource for localization, and then returns
    /// the localized string. If the targeted language resource cannot be found, it
    /// falls back to English (`"en"`) or the module's default localization.
    ///
    /// - Returns: A localized version of the original string.
    ///
    /// ## Example Usage
    /// ```swift
    /// // Suppose "Hello" is a key in your Localizable.strings files.
    /// let greetingKey = "Hello"
    /// let greetingMessage = greetingKey.localized
    ///
    /// // `greetingMessage` will be localized according to the user's preferred language
    /// // (or English, if a matching localization file isn't found).
    /// ```
    var localized: String {
        let language = UserDefaults.standard.string(forKey: UserCacheStorage.languageCode.rawValue)
        
        // First, attempt to load the localization for the user's preferred language
        if let path = Bundle.module.path(forResource: language, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return NSLocalizedString(self, bundle: bundle, comment: "")
        
        // If that fails, try English localization
        } else if let path = Bundle.module.path(forResource: "en", ofType: "lproj"),
                  let bundle = Bundle(path: path) {
            return NSLocalizedString(self, bundle: bundle, comment: "")
        
        // Finally, fall back to the module's default strings
        } else {
            return NSLocalizedString(self, bundle: .module, comment: "")
        }
    }
}
