// 
//  See LICENSE.text for this project’s licensing information.
//
//  Encodable+.swift
//
//  Created by Bilal Durnagöl on 23.03.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// An extension to the `Encodable` protocol that provides a computed property for converting
/// an encodable object into a dictionary representation.
extension Encodable {

    /// A dictionary representation of the conforming `Encodable` object.
    ///
    /// This computed property encodes the object to JSON data and then deserializes that
    /// data back into a dictionary (`[String: Any]`). If encoding or deserialization fails,
    /// it returns an empty dictionary (`[:]`).
    ///
    /// - Returns: A `[String: Any]` containing the object's properties, or an empty dictionary if encoding fails.
    ///
    /// ### Example Usage
    /// ```swift
    /// struct User: Encodable {
    ///     let id: Int
    ///     let name: String
    /// }
    ///
    /// let user = User(id: 1, name: "Alice")
    /// print(user.dictionary)
    /// // Possible output: ["id": 1, "name": "Alice"]
    /// ```
    var dictionary: [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else { return [:] }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments))
            .flatMap { $0 as? [String: Any] } ?? [:]
    }
}
