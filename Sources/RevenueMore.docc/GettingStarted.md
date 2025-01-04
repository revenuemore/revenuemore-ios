# Getting Started with RevenueMore

Welcome to the **RevenueMore** integration guide. In this document, you'll learn how to set up and implement the **RevenueMore** SDK in your mobile applications. We'll cover the initial setup, provide an overview of key features, and walk you through the implementation process step-by-step.

## Overview

**RevenueMore** is a comprehensive revenue management SDK designed to support all major mobile platforms, including iOS and Android. It simplifies in-app purchases, subscription management, and revenue tracking, allowing developers to focus on building great applications. This guide provides detailed instructions on configuring the SDK, handling purchases, restoring payments, monitoring transactions, managing subscriptions, and implementing user authentication functionalities.

## Implementation

### 1. SDK Installation

You can integrate **RevenueMore** into your project using CocoaPods, Swift Package Manager (SPM) <doc:InstallationMethods>.

---

### 2. SDK Configuration

Configures and initializes the ``RevenueMore`` system with the necessary services and managers.

Make sure you configure Purchases with your api key only.

> Important: After calling this method, you can safely access ``RevenueMore/shared`` for all functionality.
If you call ``RevenueMore/shared`` before ``RevenueMore/start(apiKey:userId:forceFinishTransaction:language:)``, it will crash at runtime.

> Experiment: You can change the SDK’s error language using the ``Language`` parameter. By default, it is set to ``Language/english``.

> Tip: To capture all errors, initialize the SDK as soon as possible, such as in your AppDelegate application:didFinishLaunchingWithOptions method:

@TabNavigator {
    @Tab("Swift-Callback") {
        ```swift
        func application(_ application: UIApplication, 
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            RevenueMore.logLevel = Log.info
            RevenueMore.start(
                apiKey: "xxx-yyy-zzz",
                userId: "rm_test_user_ios",
                forceFinishTransaction: false,
                language: .english
            )
            return true
        }
        ```
    }
    
    @Tab("Swift-Async") {
        ```swift
        @main
        struct SwiftUIApp: App {
            var body: some Scene {
                WindowGroup {
                    ContentView()
                        .task {
                            RevenueMore.logLevel = Log.info
                            RevenueMore.start(
                                apiKey: "xxx-yyy-zzz",
                                userId: "rm_test_user_ios",
                                forceFinishTransaction: false,
                                language: .english
                            )
                        }
                }
            }
        }
        ```
    }
}

You can use the ``RevenueMore/logLevel`` property to monitor your logs. These are the ``Log`` we support. The default log level is set to ``Log/trace`` in the debug environment and to ``Log/info`` in other environments.

---

### 3. Fetch Offerings

You need to fetch your offerings before making a purchase. We offer many features for ``Offerings``. You can integrate them into your application using ``RevenueMore/getOfferings(completion:)`` or  ``RevenueMore/getOfferings()`` methods. ``Offering`` provides you with ``RevenueMoreProduct`` properties (price, title, duration, etc.).

@TabNavigator {
    @Tab("Swift-Callback") {
        ```swift
        RevenueMore.shared.getOfferings { result in
            switch result {
            case .success(let offerings):
                // Offerings have been fetched
            case .failure(let error):
                // Handle the error.
            }
        }
        ```
    }
    
    @Tab("Swift-Async") {
        ```swift
        Task {
            do {
                let products = try await RevenueMore.shared.getOfferings()
                // Offerings have been fetched
            } catch {
                // Handle the error.
            }
        }
        ```
    }
}

If you want to view the default offer in the dashboard, you can use the ``Offerings/currentOffering`` property. If you want to fetch a different offer, you can use the ``Offerings/offering(with:)`` method. You can show different offers to users with the ``Offerings/triggers`` property.

---

### 4. Make a Purchase

After fetching the offers, you need to select an offer and call the ``RevenueMore/purchase(product:quantity:simulateAskToBuy:completion:)`` or ``RevenueMore/purchase(product:quantity:simulateAskToBuy:)`` methods. With this method, **RevenueMore** automatically handles the purchase process and displays it on your **RevenueMore** dashboard.

@TabNavigator {
    @Tab("Swift-Callback") {
        ```swift
        RevenueMore.shared.purchase(product: product) { result in
            switch result {
            case .success(let transaction):
                // You have purchased. You can open premium features.
            case .failure:
                // Handle the error.
            }
        }
        ```
    }
    
    @Tab("Swift-Async") {
        ```swift
        Task {
            do {
                let transaction = try await RevenueMore.shared.purchase(product: product)
                // You have purchased. You can open premium features.
            } catch {
                // Handle the error.
            }
        }
        ```
    }
}

When the purchase method succeeds, it returns the ``RevenueMorePaymentTransaction`` property. With this property, you can access values such as ``RevenueMorePaymentTransaction/transactionIdentifier``, ``RevenueMorePaymentTransaction/productId``, ``RevenueMorePaymentTransaction/transactionDate``.

---

### 4. Fetch Entitlements(User Status)

``Entitlements``, typically represent the access levels or subscription statuses that a user has earned based on their purchases. With ``RevenueMore/getEntitlements()`` or ``RevenueMore/getEntitlements(completion:)`` methods, you can fetch the user’s purchases and check if they have an active premium subscription using ``Entitlements/isPremium``.

@TabNavigator {
    @Tab("Swift-Callback") {
        ```swift
        RevenueMore.shared.getEntitlements { result in
            case .success(let entitlements):
                // Entitlements have been fetched.
            case .failure(let error):
                // Handle the error.
        }
        ```
    }
    
    @Tab("Swift-Async") {
        ```swift
        Task {
            do {
                let entitlements = try await RevenueMore.shared.getEntitlements()
                // Entitlements have been fetched.
            } catch {
                // Handle the error.
            }
        }
        ```
    }
}

---

### 5. Restore Payment

If you are unsure whether the user has an active purchase, **RevenueMore** provides you with the ``RevenueMore/restorePayment()`` or ``RevenueMore/restorePayment(completion:)`` method. With this method, we recheck their payments and return the ``RevenueMorePaymentTransaction`` to you.

@TabNavigator {
    @Tab("Swift-Callback") {
        ```swift
        RevenueMore.shared.restorePayment { result in
            switch result {
            case .success(let transactions):
                // Handle restored transactions.
            case .failure(let error):
                // Handle error.
            }
        }
        ```
    }
    
    @Tab("Swift-Async") {
        ```swift
        Task {
            do {
                let restoredTransactions = try await RevenueMore.shared.restorePayment()
                // Process restored transactions.
            } catch {
                // Handle the error.
            }
        }
        ```
    }
}

@Metadata {
    @PageColor(purple)
    @PageKind(sampleCode)
    @TitleHeading("Developer documentation")
    @CallToAction(url: "https://github.com/revenuemore/revenuemore-ios", purpose: link, label: Repository)
}
