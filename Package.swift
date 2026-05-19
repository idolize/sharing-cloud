// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "sharing-cloud",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v9),
    ],
    products: [
        .library(
            name: "SharingCloud",
            targets: ["SharingCloud"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-sharing", from: "2.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.5.1"),
    ],
    targets: [
        .target(
            name: "SharingCloud",
            dependencies: [
                .product(name: "Sharing", package: "swift-sharing"),
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "SharingCloudTests",
            dependencies: [
                "SharingCloud",
                .product(name: "DependenciesTestSupport", package: "swift-dependencies"),
            ],
            path: "Tests/SharingCloudTests"
        ),
    ]
)
