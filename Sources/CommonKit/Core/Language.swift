// 
//  See LICENSE.text for this project’s licensing information.
//
//  Language.swift
//
//  Created by Bilal Durnagöl on 10.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

/// An enumeration representing different languages and their variations.
///
/// The `Language` enum provides cases for broad language categories (e.g., `.english`, `.turkish`)
/// and nested enums for more detailed language variations (e.g., `.English.us`, `.Chinese.simplified`).
public enum Language: Equatable {
    
    /// Represents the English language.
    case english
    
    /// Represents the Turkish language.
    case turkish

    /// A nested namespace to represent different variants of the Chinese language.
    ///
    /// - `simplified`: Simplified Chinese (commonly used in mainland China)
    /// - `traditional`: Traditional Chinese (commonly used in Taiwan)
    /// - `hongKong`: Traditional Chinese specific to Hong Kong (includes certain unique phrases)
    public enum Chinese {
        /// Simplified Chinese (commonly used in mainland China).
        case simplified
        
        /// Traditional Chinese (commonly used in Taiwan).
        case traditional
        
        /// Traditional Chinese used in Hong Kong (includes certain unique phrases).
        case hongKong
    }
}

extension Language {
    
    // MARK: - Computed Properties
    
    /// A string representing the language code (e.g., `"en"`, `"tr"`).
    ///
    /// This code is typically used for localization or for configuring language preferences.
    var code: String {
        switch self {
        case .english:
            return "en"
        case .turkish:
            return "tr"
        }
    }

    /// A user-friendly name for the language.
    ///
    /// For example, `"English"` for `.english` and `"Türkçe"` for `.turkish`.
    var name: String {
        switch self {
        case .english:
            return "English"
        case .turkish:
            return "Türkçe"
        }
    }
}

extension Language {
    
    // MARK: - Initializers
    
    /// Creates a new `Language` instance from a language code string.
    ///
    /// - Parameter languageCode: A string containing the language code or locale identifier (e.g., `"en"`, `"en-US"`, `"tr"`, `"tr-TR"`).
    /// - Returns: A `Language` instance if the code matches known patterns; otherwise, `nil`.
    ///
    /// This initializer will match:
    /// - `"en"`, `"en-US"` → `Language.english`
    /// - `"tr"`, `"tr-TR"` → `Language.turkish`
    /// - All other values → `nil`
    init?(languageCode: String?) {
        guard let languageCode = languageCode else { return nil }
        switch languageCode {
        case "en", "en-US":
            self = .english
        case "tr", "tr-TR":
            self = .turkish
        default:
            return nil
        }
    }
}
