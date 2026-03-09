# CLAUDE.md - RevenueMore iOS SDK

## Project Overview

RevenueMore is an iOS SDK for in-app purchase management, subscription handling, and revenue tracking. It supports iOS 12+, macOS 10.13+, tvOS 12+, watchOS 9+, and visionOS 1.0+.

- **Language**: Swift 5.9+
- **License**: MIT
- **Version**: 0.1.5
- **Distribution**: Swift Package Manager & CocoaPods
- **Repo**: https://github.com/revenuemore/revenuemore-ios

## Architecture

Clean Architecture / Layered pattern with 12 feature modules:

```
Sources/
├── RevenueMore/       # Public API (singleton: RevenueMore.shared)
├── NetworkKit/        # HTTP client, endpoints, response handling
├── DomainKit/         # Business logic, services, models (includes SubscriptionGroupEndpoints, SubscriptionGroups, SubscriptionGroupServices)
├── CommonKit/         # Errors, utilities, extensions, localization
├── LoggerKit/         # Logging system
├── CacheKit/          # UserDefaults-based persistence
├── EntitlementKit/    # Entitlement management
├── OfferingKit/       # Offerings/products management
├── PurchaseKit/       # Purchase transaction handling
├── UserKit/           # User session management
├── TransactionKit/    # Transaction management
├── StoreKit1/         # StoreKit 1 integration (iOS 12+)
├── StoreKit2/         # StoreKit 2 integration (iOS 15+)
└── Resources/         # Localization strings
```

**Key patterns**: Protocol-oriented design, Manager pattern, Service pattern, Singleton (`RevenueMore.shared`), closure-based callbacks + async/await.

## Build & Test Commands

```bash
# Install dependencies
bundle install

# Run lint + tests (CI pipeline)
fastlane release

# Run tests only
fastlane build_unit_test

# Run SwiftLint only
fastlane lint

# Build with SPM
swift build

# Run tests with SPM
swift test

# Setup development environment
fastlane setup_dev
```

## SwiftLint Rules (.swiftlint-ci.yml)

- **Disabled**: `nesting`, `trailing_whitespace`
- **Line length**: 160 (warning), ignores comments & interpolated strings
- **File length**: 600 (warning)
- **Function body length**: 60 (warning)
- **Cyclomatic complexity**: ignores case statements
- **Scope**: Only `Sources/` directory
- CI runs with `strict: true` (warnings = failures)

## CI/CD

- **PR to master**: GitHub Actions runs SwiftLint + Fastlane tests (`pull_request.yml`)
- **Push to master**: DocC documentation auto-deploys to GitHub Pages (`docc.yml`)
- **Fastlane**: Used for lint, test, and documentation lanes

## Testing

- Tests in `Tests/RevenueMoreTests/` mirroring source structure
- Mock objects in `Tests/RevenueMoreTests/Resources/Mocks/`
- JSON fixtures in `Tests/RevenueMoreTests/Resources/JSON/`
- StoreKit test configuration: `StoreConfiguration.storekit`
- Naming convention: `*Tests.swift` for test files, `Mock*` for mocks

## Key Public API

Entry point: `RevenueMore.shared`

- `start(apiKey:userId:forceFinishTransaction:language:environment:)` - Initialize
- `getOfferings(completion:)` / `getOfferings() async` - Fetch offerings
- `getEntitlements(completion:)` / `getEntitlements() async` - Fetch entitlements
- `purchase(product:completion:)` / `purchase(product:) async` - Make purchase
- `restorePayment(completion:)` / `restorePayment() async` - Restore purchases
- `login(userId:completion:)` - User login
- `logout()` - User logout
- `canMakePayments() -> Bool` - Check if user can make payments (static)
- `listenPaymentTransactions(completion:)` / `listenPaymentTransactions() async` - Listen for payment transaction updates
- `showManageSubscriptions(completion:)` / `showManageSubscriptions() async` - Present manage subscriptions screen

## Branch Naming Convention

Pattern: `feature/`, `fix/`, `refactor/` prefixes (e.g., `feature/subscription-groups-endpoint`)

## Important Notes

- Single SPM target (`RevenueMore`) containing all modules - no inter-module SPM dependencies
- CocoaPods spec requires `StoreKit` framework
- Ruby 2.7.2 with Bundler for Fastlane
- DocC documentation at `Sources/RevenueMore.docc/`
