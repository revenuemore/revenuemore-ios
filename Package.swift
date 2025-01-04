// swift-tools-version: 5.9
//
//  See LICENSE.text for this project’s licensing information.
//
//  Package.swift
//
//  Created by Bilal Durnagöl on 22.02.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "RevenueMore",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_10),
        .visionOS(.v1),
        .tvOS(.v9),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "RevenueMore",
            targets: ["RevenueMore"])
    ],
    targets: [
        .target(
            name: "RevenueMore",
            path: "Sources"
        ),
        .testTarget(
            name: "RevenueMoreTests",
            dependencies: ["RevenueMore"],
            resources: [
                .copy("Resources/JSON/paywalls_response.json"),
                .copy("Resources/JSON/user_update_success_response.json"),
                .copy("Resources/JSON/fetch_subscriptions_response.json"),
                .copy("Resources/StoreConfiguration.storekit")
            ]
        )
    ]
)
