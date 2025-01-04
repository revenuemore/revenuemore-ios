<h1 align="center">Official RevenueMore SDK for Apple</h1>
<h3 align="center">iOS / tvOS / macOS / watchOS / VisionOS</h3>

![Spm](https://img.shields.io/badge/Spm-compatible-green?style=flat-square&logo=swift&logoColor=white)
![CocoaPods](https://img.shields.io/badge/CocoaPods-compatible-green?style=flat-square&logo=cocoapods&logoColor=white)
![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20VisionOS-blue?style=flat-square&logo=apple&logoColor=white)

---
## Overview

**RevenueMore** is a powerful SDK designed to streamline revenue management across iOS, Android, and other mobile platforms. Simplify in-app
purchases, subscription management, and revenue tracking with ease.

- **Easy Integration:** Quickly integrate **RevenueMore** into your projects with our straightforward documentation.
- **Subscription Management:** Offer flexible subscription models to your users.
- **Detailed Analytics:** Monitor your revenue performance in real-time with comprehensive reports.
- **Cross-Platform Support:** Compatible with iOS, Android, and major mobile platforms to reach a wider audience.
- **Secure Data Handling:** Ensure the protection and privacy of user data with our secure infrastructure.
- **Automatic Updates:** Stay up-to-date with the latest mobile OS versions and features through continuous SDK updates.

**Optimize and manage your mobile app revenues effectively with **RevenueMore**. Get started by visiting our [documentation page](doc:GettingStarted).**

## Initialization

> [!TIP]
> *To capture all errors, initialize the SDK as soon as possible, such as in your AppDelegate application:didFinishLaunchingWithOptions method:*

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

 > **For SwiftUI**
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

## Requirements
- Xcode 15.0+

| Platform | Minimum target |
|----------|----------------|
| iOS      | 9.0+          |
| tvOS     | 9.0+          |
| macOS    | 10.10+         |
| watchOS  | 9.0+           |
| visionOS | 1.0+           |
