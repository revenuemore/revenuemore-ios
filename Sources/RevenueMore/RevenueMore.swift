//
//  See LICENSE.text for this project’s licensing information.
//
//  RevenueMore.swift
//
//  Created by Bilal Durnagöl on 22.02.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

// swiftlint:disable force_cast

/// A top-level class that provides revenue, subscription, and entitlement functionalities.
///
/// ``RevenueMore`` acts as the primary interface for your app's in-app purchase (IAP) infrastructure.
/// It encapsulates multiple managers and services, including StoreKit, user sessions, paywall handling,
/// subscription fetching, receipt validation, and transaction management.
///
/// **Thread-Safety**:
/// - Marked `@unchecked Sendable` to indicate it can be passed across concurrency boundaries.
///   However, it uses various managers internally that handle their own concurrency operations.
///
/// **Usage**:
/// - Ensure you call ``RevenueMore/start(apiKey:userId:forceFinishTransaction:language:)``  before accessing ``RevenueMore/shared``.
/// - Utilize the shared instance to manage offerings, handle purchases, restore transactions, and manage user sessions.
///
/// **Example**:
/// ```swift
/// // Initialize RevenueMore
/// RevenueMore.start(
///     apiKey: "your-secure-api-key",
///     userId: "user_1234",
///     forceFinishTransaction: true,
///     language: .english
/// )
///
/// // Accessing the shared instance
/// let revenueMoreInstance = RevenueMore.shared
///
/// // Fetch offerings
/// revenueMoreInstance.getOfferings { result in
///     switch result {
///     case .success(let offerings):
///         // Handle successful offerings retrieval
///         print("Offerings: \(offerings)")
///     case .failure(let error):
///         // Handle error
///         print("Error fetching offerings: \(error.customMessage)")
///     }
/// }
///
/// // Initiate a purchase
/// if let product = offerings.offerings.first?.products.first {
///     revenueMoreInstance.purchase(product: product) { purchaseResult in
///         switch purchaseResult {
///         case .success(let transaction):
///             print("Purchase successful: \(transaction.id)")
///         case .failure(let error):
///             print("Purchase failed: \(error.customMessage)")
///         }
///     }
/// }
/// ```
public final class RevenueMore: @unchecked Sendable {
    
    // MARK: - Public Properties
    
    /// The shared ``RevenueMore`` singleton instance.
    ///
    /// - Important: This property will cause a runtime error (`fatalError`) if
    ///   `start(apiKey:userId:forceFinishTransaction:language:)` has not been called yet.
    ///
    /// **Example Usage**:
    /// ```swift
    /// // Accessing the singleton instance after calling .start(...)
    /// let revenueMoreInstance = RevenueMore.shared
    /// ```
    public static var shared: RevenueMore {
        guard let revenueMore = Self.revenueMore.value else {
            fatalError(Localizations.RevenueMoreError.notInitialize)
        }
        return revenueMore
    }

    /// The logging level for ``RevenueMore``.
    ///
    /// Use this property to control the verbosity of logs generated by ``RevenueMore``.
    /// The default value depends on internal settings or environment variables.
    ///
    /// **Example Usage**:
    /// ```swift
    /// RevenueMore.logLevel = .debug
    /// ```
    public static var logLevel: LogLevel {
        get { internalLogLevel }
        set { internalLogLevel = newValue }
    }

    /**
     A Boolean indicating whether the Ask to Buy / SCA (Strong Customer Authentication) purchase flow
     should be simulated in the sandbox environment.

     - Note: Set this property to `true` **only** for testing or QA environments.
     - SeeAlso: [Apple Support – Approve what kids buy with Ask to Buy](https://support.apple.com/en-us/HT201079)

     **Example Usage**:
     ```swift
     RevenueMore.simulatesAskToBuyInSandbox = true
     ```
     */
    public static var simulatesAskToBuyInSandbox: Bool {
        return false
    }

    // MARK: - Public Class Methods
    
    /**
     Checks whether the user can make payments through the App Store.
     
     This method internally calls `PurchaseManager.canMakePayments()` to verify the
     system's readiness to process payments. If this returns `false`, you may want to
     disable purchase functionality in your UI.

     - Returns: A `Bool` value indicating whether in-app purchases are allowed on this device.
     - Note: The user might have restricted payments (e.g., parental controls, or Ask to Buy).

     **Example Usage**:
     ```swift
     if RevenueMore.canMakePayments() {
         // Enable purchase buttons
     } else {
         // Disable purchase buttons or notify the user
     }
     ```
     */
    public static func canMakePayments() -> Bool {
        return PurchaseManager.canMakePayments()
    }

    /**
     Configures and initializes the ``RevenueMore`` system with the necessary services and managers.
     
     After calling this method, you can safely access ``RevenueMore/shared`` for all functionality.
     If you call ``RevenueMore/shared`` before `start(...)`, it will crash at runtime.
     
     - Parameters:
       - apiKey: A string that authenticates your backend configuration and fetches required resources.
       - userId: An optional string representing the current user's ID; if `nil`, an anonymous user session may be created.
       - forceFinishTransaction: A boolean indicating whether pending StoreKit transactions should be finalized automatically.
       - language: An optional ``Language`` enumeration value to set the app's preferred language.
     
     **Example Usage**:
     ```swift
     RevenueMore.start(
       apiKey: "my-secure-api-key",
       userId: "user_1234",
       forceFinishTransaction: true,
       language: .english
     )
     ```
     
     **Security Note**:
     Ensure that you pass an **encrypted** `userId` if you are concerned about user privacy or tampering.
     */
    public static func start(
        apiKey: String,
        userId: String? = nil,
        forceFinishTransaction: Bool = false,
        language: Language? = nil
    ) {
        // Log a message indicating that the user ID must be encrypted for security purposes
        🐛("You must send the user_id encrypted for your security.")

        let userCache = UserCache()
        let userManager = UserManager(userCache: userCache)

        // Logs in or creates an anonymous user
        let user = userManager.login(userId: userId)
        userManager.setLanguage(language)
        
        let backendConfigurator = BackendConfigurator(apiKey: apiKey, userId: user.userId, userUUID: user.uuid)
        let paywallsServices = PaywallServices(backendConfigurator: backendConfigurator)
        let subscriptionsServices = SubscriptionServices(backendConfigurator: backendConfigurator)
        
        let userServices = UserServices(backendConfigurator: backendConfigurator)
        let storeKit1Fetcher = StoreKit1Fetcher()
        let storeKit1Purchase = StoreKit1Purchase(forceFinishTransaction: forceFinishTransaction)
        let receiptManager = ReceiptManager()

        let storeKit1Manager = StoreKit1Manager(
            userManager: userManager,
            storeKit1Fetcher: storeKit1Fetcher,
            storeKit1Purchase: storeKit1Purchase
        )

        let entitlementManager = EntitlementManager(
            subscriptionsServices: subscriptionsServices,
            userServices: userServices,
            userManager: userManager,
            backendConfigurator: backendConfigurator
        )

        // Construct a new instance of RevenueMore
        Self.revenueMore.modify { currentInstance in
            let newInstance = RevenueMore(
                userCache: userCache,
                userManager: userManager,
                storeKit1Manager: storeKit1Manager,
                paywallServices: paywallsServices,
                subscriptionsServices: subscriptionsServices,
                receiptManager: receiptManager,
                entitlementManager: entitlementManager,
                backendConfigurator: backendConfigurator,
                forceFinishTransaction: forceFinishTransaction
            )
            currentInstance = newInstance
            return newInstance
        }

        🗣("RevenueMore is configured. apiKey: \(apiKey)")
    }

    // MARK: - Public Instance Methods (Non-Async)
    
    /// Fetches and returns the currently available offerings (packages/products) via the ``OfferingManager``.
    ///
    /// - Parameter completion: A closure called with a `Result` that, on success,
    ///   contains an ``Offerings`` object, or on failure, a ``RevenueMoreError``.
    /// - Note: This method is non-async to provide compatibility with older systems or
    ///   synchronous-style code bases.
    ///
    /// **Example Usage**:
    /// ```swift
    /// RevenueMore.shared.getOfferings { result in
    ///     switch result {
    ///     case .success(let offerings):
    ///         // Process offerings
    ///     case .failure(let error):
    ///         // Handle error
    ///     }
    /// }
    /// ```
    public func getOfferings(completion: @escaping @Sendable (Result<Offerings, RevenueMoreError>) -> Void) {
        self.getOfferings(completionHandler: completion)
    }

    /// Starts listening for payment transactions and returns them through the callback.
    ///
    /// - Parameter completion: A closure called whenever a payment transaction update is received.
    ///   - On success, returns a ``RevenueMorePaymentTransaction``.
    ///   - On failure, returns a ``RevenueMoreError``.
    ///
    /// This method effectively starts a listener on the underlying transaction manager.
    /// The callback may be invoked multiple times if multiple transactions occur.
    ///
    /// **Example Usage**:
    /// ```swift
    /// RevenueMore.shared.listenPaymentTransactions { result in
    ///     switch result {
    ///     case .success(let transaction):
    ///         // Handle successful transaction
    ///     case .failure(let error):
    ///         // Handle error
    ///     }
    /// }
    /// ```
    public func listenPaymentTransactions(completion: @escaping @Sendable (Result<RevenueMorePaymentTransaction, RevenueMoreError>) -> Void) {
        listenTransactions(completion: completion)
    }

    /// Fetches and returns the current entitlements assigned to the user.
    ///
    /// - Parameter completion: A closure called with a `Result` containing an ``Entitlements`` object on success,
    ///   or a ``RevenueMoreError`` on failure.
    /// - Note: This method is non-async to maintain older codebase compatibility.
    ///
    /// **Example Usage**:
    /// ```swift
    /// RevenueMore.shared.getEntitlements { result in
    ///     switch result {
    ///     case .success(let entitlements):
    ///         // Use entitlements
    ///     case .failure(let error):
    ///         // Handle error
    ///     }
    /// }
    /// ```
    public func getEntitlements(completion: @escaping @Sendable (Result<Entitlements, RevenueMoreError>) -> Void) {
        self.getEntitlements(completionHandler: completion)
    }

    /// Initiates an in-app purchase flow for a specified product.
    ///
    /// - Parameters:
    ///   - product: A ``RevenueMoreProduct`` describing the product to purchase.
    ///   - quantity: An integer specifying how many units of the product the user wants to buy. Defaults to 1.
    ///   - simulateAskToBuy: If `true`, simulates the Ask to Buy flow in sandbox environments. Defaults to `false`.
    ///   - completion: A closure invoked with the result of the purchase.
    ///     - On success, returns a ``RevenueMorePaymentTransaction``.
    ///     - On failure, returns a ``RevenueMoreError``.
    ///
    /// **Example Usage**:
    /// ```swift
    /// RevenueMore.shared.purchase(product: someProduct) { result in
    ///     switch result {
    ///     case .success(let transaction):
    ///         // Handle successful purchase
    ///     case .failure(let error):
    ///         // Handle error
    ///     }
    /// }
    /// ```
    public func purchase(
        product: RevenueMoreProduct,
        quantity: Int = 1,
        simulateAskToBuy: Bool = false,
        completion: @escaping @Sendable (Result<RevenueMorePaymentTransaction, RevenueMoreError>) -> Void
    ) {
        self.purchase(
            with: product,
            quantity: quantity,
            simulateAskToBuy: simulateAskToBuy,
            completion: completion
        )
    }

    /// Restores previously made purchases for the current user.
    ///
    /// - Parameter completion: A closure called with the result of the restoration.
    ///   - On success, contains an array of ``RevenueMorePaymentTransaction``.
    ///   - On failure, a ``RevenueMoreError``.
    ///
    /// **Note**:
    /// - Typically used to restore non-consumable purchases or auto-renewable subscriptions.
    /// - Ensure you call this method from a place in your UI that makes sense (e.g., a "Restore" button).
    ///
    /// **Example Usage**:
    /// ```swift
    /// RevenueMore.shared.restorePayment { result in
    ///     switch result {
    ///     case .success(let transactions):
    ///         // Handle restored transactions
    ///     case .failure(let error):
    ///         // Handle error
    ///     }
    /// }
    /// ```
    public func restorePayment(completion: @escaping @Sendable (Result<[RevenueMorePaymentTransaction], RevenueMoreError>) -> Void) {
        restore(completion: completion)
    }

    /// Logs out the current user, resetting any stored user session data.
    ///
    /// After calling this method, your app may prompt the user to log in again
    /// or continue with an anonymous session.
    ///
    /// **Example Usage**:
    /// ```swift
    /// RevenueMore.shared.logout()
    /// ```
    public func logout() {
        logoutUser()
    }

    /// Logs in a user with a specified user ID.
    ///
    /// - Parameters:
    ///   - userId: A string representing the user ID to be used for the session.
    ///   - completion: A closure called once the login process is completed.
    ///
    /// **Behavior**:
    /// - If a user is already logged in, this method will switch the session to the new user.
    /// - If `userId` is `nil`, an anonymous session may be created (depending on your logic).
    ///
    /// **Example Usage**:
    /// ```swift
    /// RevenueMore.shared.login(userId: "new_user_5678") {
    ///     // Handle post-login actions
    /// }
    /// ```
    public func login(userId: String, completion: @escaping @Sendable () -> Void) {
        login(userId: userId, completionHandler: completion)
    }

    /// Presents the system's "Manage Subscriptions" screen for the current user.
    ///
    /// - Parameter completion: A closure called with a boolean indicating whether the manage subscriptions screen
    ///   was successfully shown (`true`) or not (`false`).
    /// - Note: Only available for iOS and macOS (and possibly xrOS). It's unavailable for `watchOS` and `tvOS`.
    ///
    /// **Example Usage**:
    /// ```swift
    /// RevenueMore.shared.showManageSubscriptions { success in
    ///     if success {
    ///         print("Manage Subscriptions screen presented successfully.")
    ///     } else {
    ///         print("Failed to present Manage Subscriptions screen.")
    ///     }
    /// }
    /// ```
    @MainActor
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    public func showManageSubscriptions(completion: @escaping (Bool) -> Void) {
        self.showManageSubscriptionsNonAsync(completion: completion)
    }

    // MARK: - Private Static Properties
    
    /// A thread-safe storage for the current ``RevenueMore`` instance.
    ///
    /// Initially set to `nil`. Calling ``RevenueMore/start(apiKey:userId:forceFinishTransaction:language:)`` updates this value.
    private static let revenueMore: ThreadSafe<RevenueMore?> = .init(nil)

    // MARK: - Private Properties
    
    /// An internal reference to a StoreKit2 manager, available if iOS 15+ (or equivalent).
    ///
    /// Marked `any Sendable` to provide concurrency safety. If the system is below iOS 15,
    /// this property is `nil` and StoreKit2 is not used.
    private let _storeKit2Manager: (any Sendable)?
    
    /// An internal reference to a StoreKit2 fetcher, available if iOS 15+ (or equivalent).
    private let _storeKit2Fetcher: (any Sendable)?
    
    /// An internal reference to a StoreKit2 purchase manager, available if iOS 15+ (or equivalent).
    private let _storeKit2Purchase: (any Sendable)?
    
    /// A cache used for storing user-specific data, such as user IDs or preferences.
    private let userCache: UserCache
    
    /// A configurator handling backend service connections (e.g., endpoints, user authentication).
    internal let backendConfigurator: BackendConfigurator
    
    /// A manager handling StoreKit1 flows, such as fetching and purchasing products on systems below iOS 15.
    internal let storeKit1Manager: StoreKit1Manager
    
    /// Manages the current user’s state (logged in, anonymous, IDs, etc.).
    internal let userManager: UserManager
    
    /// Handles entitlement logic, such as fetching subscription data and converting it into user entitlements.
    internal let entitlementManager: EntitlementManager
    
    /// Manages paywall or offering logic to determine which products or promotions are shown to the user.
    internal let offeringManager: OfferingManager
    
    /// A high-level purchase manager that coordinates with StoreKit managers, subscription services, and receipt manager.
    internal let purchaseManager: PurchaseManager
    
    /// Manages transactions in either StoreKit1 or StoreKit2. Listens for updates and provides transaction details.
    internal let transactionManager: TransactionManager

    // MARK: - Computed Properties (StoreKit2) - iOS 15+ only
    
    /// A computed property providing a `StoreKit2Manager` if the system meets the iOS 15+ requirement.
    ///
    /// - Returns: A `StoreKit2Manager` instance.
    /// - Warning: Force-casts `self._storeKit2Manager`. Crashes if `nil` on unsupported systems.
    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    internal var storeKit2Manager: StoreKit2Manager {
        return self._storeKit2Manager! as! StoreKit2Manager
    }

    /// A computed property providing a `StoreKit2Fetcher` if iOS 15+.
    ///
    /// - Returns: A `StoreKit2Fetcher` instance.
    /// - Warning: Force-casts `self._storeKit2Fetcher`. Crashes if `nil` on unsupported systems.
    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    private var storeKit2Fetcher: StoreKit2Fetcher {
        return self._storeKit2Fetcher! as! StoreKit2Fetcher
    }

    /// A computed property providing a `StoreKit2Purchase` if iOS 15+.
    ///
    /// - Returns: A `StoreKit2Purchase` instance.
    /// - Warning: Force-casts `self._storeKit2Purchase`. Crashes if `nil` on unsupported systems.
    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    private var storeKit2Purchase: StoreKit2Purchase {
        return self._storeKit2Purchase! as! StoreKit2Purchase
    }

    // MARK: - Initialization & Deinitialization
    
    /**
     Initializes a new instance of ``RevenueMore``. Called by `start(...)`.
     
     - Parameters:
       - userCache: An instance of `UserCache` for persisting user data.
       - userManager: A `UserManager` for handling user sessions (logged in or anonymous).
       - storeKit1Manager: A `StoreKit1Manager` responsible for product fetching and purchases on iOS <15.
       - paywallServices: A `PaywallServices` for fetching and managing paywalls from the backend.
       - subscriptionsServices: A `SubscriptionServices` for subscription data retrieval and updates.
       - receiptManager: A `ReceiptManager` handling local receipt validation or reading.
       - entitlementManager: An `EntitlementManager` for converting subscription data into user entitlements.
       - backendConfigurator: A `BackendConfigurator` controlling backend connections.
       - forceFinishTransaction: A boolean indicating whether pending StoreKit transactions should be finalized automatically.
     
     **Note**:
     Depending on the platform and OS version, this initializer determines whether
     to use StoreKit1 or StoreKit2 managers. On iOS 15+ (and equivalents), StoreKit2
     managers are used; otherwise, the StoreKit1 path is followed.
     
     **Example**:
     This initializer is called internally by the `start(...)` method and should not be
     called directly in your application code.
     */
    init(
        userCache: UserCache,
        userManager: UserManager,
        storeKit1Manager: StoreKit1Manager,
        paywallServices: PaywallServices,
        subscriptionsServices: SubscriptionServices,
        receiptManager: ReceiptManager,
        entitlementManager: EntitlementManager,
        backendConfigurator: BackendConfigurator,
        forceFinishTransaction: Bool
    ) {
        self.userCache = userCache
        self.storeKit1Manager = storeKit1Manager
        self.entitlementManager = entitlementManager
        self.userManager = userManager
        self.backendConfigurator = backendConfigurator

        if #available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *) {
            _storeKit2Fetcher = StoreKit2Fetcher()
            _storeKit2Purchase = StoreKit2Purchase(forceFinishTransaction: forceFinishTransaction)
            _storeKit2Manager = StoreKit2Manager(
                userManager: userManager,
                storeKit2Fetcher: _storeKit2Fetcher as! StoreKit2Fetcher,
                storeKit2Purchase: _storeKit2Purchase as! StoreKit2Purchase
            )

            // Offering Manager
            let offeringManager = OfferingManager(
                paywallServices: paywallServices,
                userManager: userManager,
                forceFinishTransaction: forceFinishTransaction,
                storeKitManager: _storeKit2Manager
            )
            self.offeringManager = offeringManager

            // Purchase Manager
            let purchaseManager = PurchaseManager(
                storeKitManager: _storeKit2Manager,
                subscriptionsServices: subscriptionsServices,
                receiptManager: receiptManager
            )
            self.purchaseManager = purchaseManager

            // Transaction Manager
            let transactionManager = TransactionManager(storeKitManager: _storeKit2Manager)
            self.transactionManager = transactionManager

        } else {
            // Fallback to StoreKit1
            _storeKit2Manager = nil
            _storeKit2Fetcher = nil
            _storeKit2Purchase = nil

            let offeringManager = OfferingManager(
                paywallServices: paywallServices,
                userManager: userManager,
                forceFinishTransaction: forceFinishTransaction,
                storeKitManager: storeKit1Manager
            )
            self.offeringManager = offeringManager

            let purchaseManager = PurchaseManager(
                storeKitManager: storeKit1Manager,
                subscriptionsServices: subscriptionsServices,
                receiptManager: receiptManager
            )
            self.purchaseManager = purchaseManager

            let transactionManager = TransactionManager(storeKitManager: storeKit1Manager)
            self.transactionManager = transactionManager
            transactionManager.startTransactionListener()
        }
    }

    /**
     Cleans up the ``RevenueMore`` instance before deinitialization.
     
     Stops listening for payment transactions in the `transactionManager`.
     
     **Example Usage**:
     This deinitializer is called automatically when the ``RevenueMore`` instance is deallocated.
     */
    deinit {
        transactionManager.stopListenPaymentTrasactions()
    }
}

// swiftlint:enable force_cast