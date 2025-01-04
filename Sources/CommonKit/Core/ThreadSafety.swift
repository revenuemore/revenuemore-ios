// 
//  See LICENSE.text for this project’s licensing information.
//
//  ThreadSafety.swift
//
//  Created by Bilal Durnagöl on 14.03.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

// swiftlint:disable identifier_name
// http://www.russbishop.net/the-law

/// A generic class that provides thread-safe access to a mutable value `T`.
///
/// `ThreadSafe<T>` uses `os_unfair_lock` to ensure mutual exclusion when reading and modifying
/// its underlying data. This means only one thread can access or modify the stored value at a time.
///
/// Example usage:
/// ```swift
/// let sharedCounter = ThreadSafe<Int>(0)
///
/// DispatchQueue.concurrentPerform(iterations: 10) { _ in
///     sharedCounter.modify { $0 += 1 }
/// }
/// print(sharedCounter.value) // 10
/// ```
internal final class ThreadSafe<T> {

    // MARK: - Private Properties

    /// A pointer to an `os_unfair_lock` used to synchronize access to `_value`.
    ///
    /// - Warning: This pointer is allocated in `init(_:)` and deallocated in `deinit`.
    private var _lock: UnsafeMutablePointer<os_unfair_lock>
    
    /// The stored value of type `T`.
    ///
    /// Access to this property should always be protected via `locked(_:)`, `modify(_:)`, or other
    /// thread-safe functions.
    private var _value: T

    // MARK: - Public Computed Properties

    /// The public interface to the stored value.
    ///
    /// Reading this property returns the stored value in a thread-safe manner.
    /// Setting this property updates the stored value in a thread-safe manner.
    var value: T {
        get { withValue { $0 } }
        set { modify { $0 = newValue } }
    }

    // MARK: - Initialization & Deinitialization

    /// Initializes a new thread-safe container with an initial value.
    ///
    /// - Parameter value: The initial value of type `T` to store.
    init(_ value: T) {
        self._value = value
        _lock = UnsafeMutablePointer<os_unfair_lock>.allocate(capacity: 1)
        _lock.initialize(to: os_unfair_lock())
    }

    deinit {
        _lock.deallocate()
    }

    // MARK: - Locking & Assertions

    /// Acquires the lock and executes a closure, ensuring thread-safety for its duration.
    ///
    /// - Parameter f: A closure that returns a value of generic type `ReturnValue`.
    /// - Returns: The result from the closure `f`.
    /// - Throws: Rethrows any error encountered within `f`.
    ///
    /// Example usage:
    /// ```swift
    /// let result = try myThreadSafeInstance.locked {
    ///     // thread-safe operations
    ///     return someCalculation()
    /// }
    /// ```
    func locked<ReturnValue>(_ f: () throws -> ReturnValue) rethrows -> ReturnValue {
        os_unfair_lock_lock(_lock)
        defer { os_unfair_lock_unlock(_lock) }
        return try f()
    }

    /// Asserts that the current thread holds the lock.
    ///
    /// This is useful for debugging or verifying lock ownership during development.
    func assertOwned() {
        os_unfair_lock_assert_owner(_lock)
    }

    /// Asserts that the current thread does **not** hold the lock.
    ///
    /// Useful for debugging or verifying lock ownership during development.
    func assertNotOwned() {
        os_unfair_lock_assert_not_owner(_lock)
    }

    // MARK: - Modifying & Accessing the Value

    /// Applies a mutation to the underlying value in a thread-safe manner.
    ///
    /// - Parameter action: A closure that takes an inout reference to the stored value.
    /// - Returns: The result of the closure.
    /// - Throws: Rethrows any error that the closure might throw.
    ///
    /// Example usage:
    /// ```swift
    /// let oldValue = try shared.modify { value in
    ///     let currentValue = value
    ///     value += 1
    ///     return currentValue
    /// }
    /// // oldValue contains the previous state, value was incremented by 1.
    /// ```
    @discardableResult
    func modify<Result>(_ action: (inout T) throws -> Result) rethrows -> Result {
        return try locked {
            try action(&_value)
        }
    }

    /// Replaces the underlying value with a new value, returning the old value in a thread-safe manner.
    ///
    /// - Parameter newValue: The new value to be set.
    /// - Returns: The old value before the replacement.
    ///
    /// Example usage:
    /// ```swift
    /// let oldValue = shared.getAndSet(10)
    /// print("Old: \(oldValue), New: \(shared.value)")  // "Old: X, New: 10"
    /// ```
    @discardableResult
    func getAndSet(_ newValue: T) -> T {
        return self.modify { currentValue in
            defer { currentValue = newValue }
            return currentValue
        }
    }

    /// Retrieves the underlying value in a thread-safe manner, without modifying it.
    ///
    /// - Parameter action: A closure that takes the current value by copy.
    /// - Returns: The result of the closure.
    /// - Throws: Rethrows any error encountered within the closure.
    ///
    /// Example usage:
    /// ```swift
    /// let length = shared.withValue { value in
    ///     return value.count
    /// }
    /// ```
    @discardableResult
    func withValue<Result>(_ action: (T) throws -> Result) rethrows -> Result {
        return try locked {
            try action(_value)
        }
    }
}
// swiftlint:enable identifier_name
