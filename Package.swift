// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Nostr",
    platforms: [.iOS(.v17), .macOS(.v14), .macCatalyst(.v17), .visionOS(.v1), .tvOS(.v17), .watchOS(.v10)],
    products: [
        .library(
            name: "Nostr",
            targets: ["Nostr"]),
    ],
    dependencies: [
        .package(url: "https://github.com/21-DOT-DEV/swift-secp256k1.git", exact: "0.17.0")
    ],
    targets: [
        .target(
            name: "Nostr", dependencies: [
                .product(name: "secp256k1", package: "swift-secp256k1")
            ]),
        .testTarget(
            name: "NostrTests",
            dependencies: ["Nostr"]),
    ]
)
