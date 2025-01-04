// 
//  See LICENSE.text for this project’s licensing information.
//
//  EntitlementManager.swift
//
//  Created by Bilal Durnagöl on 21.07.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

/// A protocol that defines an interface for managing and fetching user entitlements.
///
/// Types conforming to `EntitlementManagerProtocol` should provide implementations
/// that fetch entitlements from the backend and update the user ID as needed.
protocol EntitlementManagerProtocol {

    /// Fetches the current user's entitlements from the backend.
    ///
    /// - Parameter completion: A closure called with the result of the fetch operation.
    ///   - On success, returns a `Result` containing an ``Entitlements`` object.
    ///   - On failure, returns a `Result` containing a `RevenueMoreErrorInternal`.
    func fetchEntitlements(completion: @escaping @Sendable (Result<Entitlements, RevenueMoreErrorInternal>) -> Void)

    /// Updates the current user's ID in the system.
    ///
    /// - Parameters:
    ///   - userId: The new user identifier to be set.
    ///   - completion: A closure that is called once the operation is complete.
    func updateUserId(userId: String, completion: @escaping @Sendable () -> Void)
}

/// A manager class responsible for handling entitlements.
///
/// `EntitlementManager` implements the `EntitlementManagerProtocol` to manage user entitlements.
/// It fetches subscription data from a remote service and updates the user ID when needed.
internal class EntitlementManager: NSObject, EntitlementManagerProtocol, @unchecked Sendable {

    // MARK: - Properties

    /// A service used for subscription-related API calls.
    private let subscriptionsServices: SubscriptionServiceable
    
    /// A service used for user-related API calls (e.g., updating user information).
    private let userServices: UserServiceable
    
    /// A manager for user-related state and logic.
    private let userManager: UserManager
    
    /// A configurator for back-end login or session operations.
    private let backendConfigurator: BackendConfiguratorProtocol

    // MARK: - Initialization

    /// Initializes a new `EntitlementManager`.
    ///
    /// - Parameters:
    ///   - subscriptionsServices: An object that conforms to `SubscriptionServiceable`,
    ///     responsible for subscription data fetching or updates.
    ///   - userServices: An object that conforms to `UserServiceable`,
    ///     responsible for user updates (e.g., updating user info).
    ///   - userManager: A `UserManager` instance that tracks user information.
    ///   - backendConfigurator: A `BackendConfiguratorProtocol` instance used
    ///     for logging in to the back-end or configuring user sessions.
    init(
        subscriptionsServices: SubscriptionServiceable,
        userServices: UserServiceable,
        userManager: UserManager,
        backendConfigurator: BackendConfiguratorProtocol
    ) {
        self.subscriptionsServices = subscriptionsServices
        self.userServices = userServices
        self.userManager = userManager
        self.backendConfigurator = backendConfigurator
    }

    // MARK: - Public Methods

    /// Fetches the current user's entitlements.
    ///
    /// - Parameter completion: A closure called with the result of the fetch operation.
    ///   - On success, contains an ``Entitlements`` object.
    ///   - On failure, contains a `RevenueMoreErrorInternal`.
    open func fetchEntitlements(
        completion: @escaping @Sendable (Result<Entitlements, RevenueMoreErrorInternal>) -> Void
    ) {
        fetchSubscriptions(completion: completion)
    }

    /// Updates the current user's ID in the system.
    ///
    /// If the `userId` has not changed or the current user is anonymous,
    /// the method updates the in-memory user ID immediately.
    /// Otherwise, it sends a user update request to the backend
    /// and updates the user ID upon success.
    ///
    /// - Parameters:
    ///   - userId: The new user identifier to be set.
    ///   - completion: A closure that is called once the operation is complete.
    open func updateUserId(userId: String, completion: @escaping @Sendable () -> Void) {
        guard userManager.userId != userId, userManager.isAnonymous else {
            login(with: userId)
            completion()
            return
        }
        let request = UserUpdate.Request(userId: userId)
        userServices.userUpdate(request: request) { [weak self] _ in
            guard let self else { return }
            login(with: userId)
            completion()
        }
    }

    // MARK: - Private Methods

    /// Fetches subscription data for the user and converts it into entitlements.
    ///
    /// - Parameter completion: A closure called with the result of the fetch operation.
    ///   - On success, contains an ``Entitlements`` object constructed from subscription data.
    ///   - On failure, contains a `RevenueMoreErrorInternal` error.
    private func fetchSubscriptions(
        completion: @escaping @Sendable (Result<Entitlements, RevenueMoreErrorInternal>) -> Void
    ) {
        let request = UserSubscription.Request(type: .all)
        subscriptionsServices.subscriptions(request: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.subscriptionsPresenter(with: response, completion: completion)
            case .failure(let error):
                completion(.failure(.fetchEntitlements(error.customMessage)))
            }
        }
    }

    /// Logs in a user with the specified `userId`, updating the back-end session.
    ///
    /// - Parameter userId: The user identifier to be used for the current session.
    private func login(with userId: String) {
        let user = userManager.login(userId: userId)
        let userID = user.userId
        let uuid = user.uuid
        backendConfigurator.login(userId: userID, userUUID: uuid)
    }

    /// Converts a subscription response into an ``Entitlements`` object and passes it to the completion closure.
    ///
    /// - Parameters:
    ///   - response: The response from the subscription service containing an array of subscriptions.
    ///   - completion: A closure that is called with the ``Entitlements`` object on success,
    ///     or a `RevenueMoreErrorInternal` on failure.
    ///
    /// This method maps each `Subscription` from the response to an `Entitlement` object,
    /// then aggregates them into an ``Entitlements`` container before returning the result.
    private func subscriptionsPresenter(
        with response: UserSubscription.Response,
        completion: @escaping @Sendable (Result<Entitlements, RevenueMoreErrorInternal>) -> Void
    ) {
        let entitlement = response.subscriptions?.map { subscription in
            Entitlement(
                productId: subscription.productId,
                renewStatus: subscription.renewStatus,
                price: subscription.price,
                currency: subscription.currency,
                purchaseDate: subscription.purchaseDate,
                quantity: subscription.quantity,
                startDate: subscription.startDate,
                renewalDate: subscription.renewalDate,
                serviceStatus: Entitlement.ServiceStatus(rawValue: subscription.serviceStatus ?? 0),
                expiresDate: subscription.expiresDate
            )
        } ?? []

        let entitlements = Entitlements(allEntitlements: entitlement)
        completion(.success(entitlements))
    }
}
