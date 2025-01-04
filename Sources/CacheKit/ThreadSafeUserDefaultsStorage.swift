// 
//  See LICENSE.text for this project’s licensing information.
//
//  ThreadSafeUserDefaultsStorage.swift
//
//  Created by Bilal Durnagöl on 14.12.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// A protocol that provides an interface for accessing and storing `String` values using user defaults.
///
/// Use this protocol to abstract away the underlying implementation of `UserDefaults`.
/// Conforming types are expected to provide implementations for retrieving and setting `Any?` values,
/// and specifically `String?` values.
protocol UserDefaultsProtocol {
    /// Returns the string associated with the specified key.
    /// - Parameter defaultName: A key in the current user defaults database.
    /// - Returns: The string associated with `defaultName`, or `nil` if the key was not found or the value is not a string.
    func string(forKey defaultName: String) -> String?
    
    /// Stores the value associated with the specified key.
    /// - Parameters:
    ///   - value: The object to store in user defaults.
    ///   - key: The key with which to associate the value.
    func setValue(_ value: Any?, forKey key: String)
}

/// Extends the built-in `UserDefaults` to conform to `UserDefaultsProtocol`.
///
/// This allows `UserDefaults` to be used wherever `UserDefaultsProtocol` is required,
/// making it easier to mock or swap implementations during testing.
extension UserDefaults: UserDefaultsProtocol {}

/// A protocol that defines a caching interface for retrieving and storing string values.
///
/// Types conforming to this protocol should provide thread-safe or otherwise
/// concurrency-friendly mechanisms (if needed) to store and retrieve strings.
protocol UserCacheStorageProtocol {
    /// Retrieves a string for the given key.
    /// - Parameter key: A key used to identify the stored value.
    /// - Returns: The string associated with `key`, or `nil` if no string is found.
    func getString(forKey key: String) -> String?
    
    /// Stores a value for the given key.
    /// - Parameters:
    ///   - value: The object to store.
    ///   - key: A key used to identify the stored value.
    func setValue(_ value: Any?, forKey key: String)
}

/// A thread-safe wrapper around a `UserDefaultsProtocol`-compliant storage.
///
/// This class ensures that any operation on the underlying `UserDefaultsProtocol` storage
/// is performed in a concurrency-safe manner using a `ThreadSafe` wrapper.
///
/// Use `ThreadSafeUserDefaultsStorage` when multiple threads may read and write
/// to user defaults in your application or library.
class ThreadSafeUserDefaultsStorage: UserCacheStorageProtocol {
    /// The thread-safe storage of the `UserDefaultsProtocol`.
    ///
    /// This property holds a `ThreadSafe` container that synchronizes
    /// access to the underlying `UserDefaultsProtocol` implementation.
    private let storage: ThreadSafe<UserDefaultsProtocol>
    
    /// Initializes a new `ThreadSafeUserDefaultsStorage` with the given `UserDefaultsProtocol`.
    /// - Parameter defaults: An instance conforming to `UserDefaultsProtocol`.
    ///   If not provided, defaults to `UserDefaults.standard`.
    init(_ defaults: UserDefaultsProtocol = UserDefaults.standard) {
        self.storage = ThreadSafe(defaults)
    }
    
    /// Retrieves a string for the given key in a thread-safe manner.
    /// - Parameter key: A key used to identify the stored value.
    /// - Returns: The string associated with `key`, or `nil` if the key is not found or the value is not a string.
    func getString(forKey key: String) -> String? {
        return storage.withValue { userDefaults in
            userDefaults.string(forKey: key)
        }
    }
    
    /// Stores a value for the given key in a thread-safe manner.
    /// - Parameters:
    ///   - value: The object to store.
    ///   - key: A key used to identify the stored value.
    func setValue(_ value: Any?, forKey key: String) {
        storage.withValue { userDefaults in
            userDefaults.setValue(value, forKey: key)
        }
    }
}
