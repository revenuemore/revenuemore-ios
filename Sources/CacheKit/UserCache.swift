// 
//  See LICENSE.text for this project’s licensing information.
//
//  UserCache.swift
//
//  Created by Bilal Durnagöl on 18.06.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// An enumeration that represents the keys used for storing user information.
///
/// Each case corresponds to a specific type of information stored in `UserCache`.
enum UserCacheStorage: String, Sendable {
    /// A key representing the user's identifier.
    case userId
    
    /// A key representing a universal unique identifier (UUID).
    case uuid
    
    /// A key representing the user's language code.
    case languageCode
}

/// A class responsible for storing and retrieving user information.
///
/// `UserCache` utilizes a `UserCacheStorageProtocol`-conforming object—by default,
/// `ThreadSafeUserDefaultsStorage`—to persist and retrieve values safely.
internal class UserCache {
    
    // MARK: - Properties
    
    /// An object conforming to `UserCacheStorageProtocol` that manages the actual data storage.
    private let storage: UserCacheStorageProtocol
    
    // MARK: - Initialization
    
    /// Initializes a new instance of `UserCache`.
    ///
    /// - Parameter storage: The storage mechanism conforming to `UserCacheStorageProtocol`.
    ///   If no parameter is provided, a `ThreadSafeUserDefaultsStorage` instance is used by default.
    public init(storage: UserCacheStorageProtocol = ThreadSafeUserDefaultsStorage()) {
        self.storage = storage
    }
    
    // MARK: - User ID
    
    /// The user's unique identifier.
    ///
    /// This property reads and writes its value using the `UserCacheStorage.userId` key in the underlying storage.
    var userId: String? {
        get {
            storage.getString(forKey: UserCacheStorage.userId.rawValue)
        }
        set {
            storage.setValue(newValue, forKey: UserCacheStorage.userId.rawValue)
        }
    }
    
    // MARK: - UUID
    
    /// A universal unique identifier (UUID).
    ///
    /// This property reads and writes its value using the `UserCacheStorage.uuid` key in the underlying storage.
    var uuid: String? {
        get {
            storage.getString(forKey: UserCacheStorage.uuid.rawValue)
        }
        set {
            storage.setValue(newValue, forKey: UserCacheStorage.uuid.rawValue)
        }
    }
    
    // MARK: - Language Code
    
    /// The user's preferred language code (e.g., `"en"`, `"fr"`, etc.).
    ///
    /// This property reads and writes its value using the `UserCacheStorage.languageCode` key in the underlying storage.
    var languageCode: String? {
        get {
            storage.getString(forKey: UserCacheStorage.languageCode.rawValue)
        }
        set {
            storage.setValue(newValue, forKey: UserCacheStorage.languageCode.rawValue)
        }
    }
}
