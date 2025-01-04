// 
//  See LICENSE.text for this project’s licensing information.
//
//  UserManager.swift
//
//  Created by Bilal Durnagöl on 8.04.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// A protocol that defines a method for generating UUID strings.
///
/// Types conforming to `UUIDGenerator` must implement a `generateUUID()` method
/// that returns a newly generated UUID as a `String`.
protocol UUIDGenerator {
    /// Generates and returns a new UUID as a string.
    func generateUUID() -> String
}

/// A default implementation of `UUIDGenerator` that uses Swift's built-in `UUID` struct.
///
/// `SystemUUIDGenerator` returns `UUID().uuidString` from its `generateUUID()` method.
struct SystemUUIDGenerator: UUIDGenerator {
    /// Generates a string representation of a new UUID by calling `UUID().uuidString`.
    func generateUUID() -> String {
        return UUID().uuidString
    }
}

/// An enumeration representing keys used in `UserManager` for storing user-related values.
///
/// - `userId`: The user's identifier.
/// - `uuid`: A unique identifier (UUID) for the user session.
enum UserManagerStorage: String {
    case userId
    case uuid
}

/// A class responsible for managing user identities and UUIDs, including anonymous sessions.
///
/// `UserManager` handles storing and retrieving a user's `userId` and `uuid` from a `UserCache`.
/// It also provides methods for logging in, logging out, and setting a preferred language.
internal class UserManager {

    // MARK: - Properties

    /// A cache instance used to store user-specific information (e.g., `userId`, `uuid`, `languageCode`).
    private let userCache: UserCache

    /// An object that generates UUID strings when needed (defaults to `SystemUUIDGenerator`).
    private let uuidGenerator: UUIDGenerator

    // MARK: - Initialization

    /// Initializes a new `UserManager` instance with a `UserCache` and an optional `UUIDGenerator`.
    ///
    /// - Parameters:
    ///   - userCache: A `UserCache` instance that stores user info, such as IDs and language codes.
    ///   - uuidGenerator: An object conforming to `UUIDGenerator` for UUID creation. Defaults to `SystemUUIDGenerator()`.
    init(
        userCache: UserCache,
        uuidGenerator: UUIDGenerator = SystemUUIDGenerator()
    ) {
        self.userCache = userCache
        self.uuidGenerator = uuidGenerator
    }

    // MARK: - Computed Properties

    /// The current user ID.
    ///
    /// If no user ID is stored in `userCache`, this property generates a new anonymous user ID
    /// (using `generateUserId(uuidGenerator:)`), stores it, and returns it.
    var userId: String {
        if let existingUserId = userCache.userId {
            return existingUserId
        }
        
        let newUserId = UserManager.generateUserId(uuidGenerator: uuidGenerator)
        userCache.userId = newUserId
        return newUserId
    }

    /// The current user's UUID.
    ///
    /// If no UUID is stored in `userCache` or if the `userId` has changed,
    /// this property generates a new UUID (using `uuidGenerator.generateUUID()`), stores it, and returns it.
    var uuid: String {
        if let existingUuid = userCache.uuid, userId == userCache.userId {
            return existingUuid
        }
        
        let newUUID = uuidGenerator.generateUUID()
        userCache.uuid = newUUID
        return newUUID
    }

    /// A Boolean value indicating whether the current user is anonymous.
    ///
    /// A user is considered anonymous if the stored `userId` begins with the string `"anonymous-"`.
    var isAnonymous: Bool {
        return userCache.userId?.hasPrefix("anonymous-") == true
    }

    // MARK: - Public Methods

    /// Logs in a user with a specified `userId`, or creates an anonymous user if `userId` is `nil`.
    ///
    /// - Parameter userId: An optional string representing the user's identifier.
    /// - Returns: A tuple containing the new or existing `userId` and `uuid`.
    ///
    /// **Behavior**:
    /// 1. If a `userId` is provided and differs from the one in `userCache`, a new UUID may be generated if the current user
    ///    isn't anonymous. The cache is then updated with the new ID and (potentially) a new UUID.
    /// 2. If `userId` is `nil` and the cache has no stored `userId`, an anonymous user ID and new UUID are generated.
    /// 3. If nothing changes, returns the existing `userId` and `uuid`.
    @discardableResult
    func login(userId: String?) -> (userId: String, uuid: String) {
        
        if let userId = userId {
            if userId != userCache.userId {
                // If the user ID changes, generate a new UUID if we're not anonymous; otherwise, reuse or create one.
                let newUUID = !isAnonymous ? uuidGenerator.generateUUID() : (userCache.uuid ?? uuidGenerator.generateUUID())
                userCache.uuid = newUUID
                userCache.userId = userId
                return (userId, newUUID)
            }
            // If the provided userId matches the one in cache, just return existing values.
            return (self.userId, self.uuid)
        }
        
        // If no userId is provided and none is stored, create a new anonymous user.
        if userCache.userId == nil {
            let newUserId = UserManager.generateUserId(uuidGenerator: uuidGenerator)
            let newUUID = uuidGenerator.generateUUID()
            userCache.uuid = newUUID
            userCache.userId = newUserId
            return (newUserId, newUUID)
        }
        
        // Otherwise, return the existing user (anonymous or known).
        return (self.userId, self.uuid)
    }

    /// Logs out the current user by assigning a new anonymous user ID and UUID.
    ///
    /// - Returns: A tuple containing the newly generated `userId` and `uuid`.
    ///
    /// **Behavior**:
    /// - Always generates a fresh `userId` (anonymous) and UUID, updating the cache with the new values.
    @discardableResult
    func logout() -> (userId: String, uuid: String) {
        let newUserId = UserManager.generateUserId(uuidGenerator: uuidGenerator)
        let newUUID = uuidGenerator.generateUUID()
        userCache.userId = newUserId
        userCache.uuid = newUUID
        return (newUserId, newUUID)
    }
    
    /// Sets the user's preferred language in the user cache.
    ///
    /// - Parameter language: A `Language` enum value, or `nil` to remove the language code.
    ///
    /// **Behavior**:
    /// - If a valid `language` is provided, its `code` is stored in the `userCache`.
    /// - If `nil`, the `languageCode` is effectively cleared.
    func setLanguage(_ language: Language?) {
        userCache.languageCode = language?.code
    }
}

// MARK: - Helpers

extension UserManager {
    /// Generates an anonymous user ID string by combining `"anonymous-"` with a UUID (hex string).
    ///
    /// - Parameter uuidGenerator: An object conforming to `UUIDGenerator`.
    /// - Returns: A string of the form `"anonymous-xxxxxxxxxxxx..."`.
    static func generateUserId(uuidGenerator: UUIDGenerator) -> String {
        let uuidString = uuidGenerator
            .generateUUID()
            .replacingOccurrences(of: "-", with: "")
            .lowercased()
        return "anonymous-\(uuidString)"
    }
}
