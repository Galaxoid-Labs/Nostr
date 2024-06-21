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
        .package(url: "https://github.com/GigaBitcoin/secp256k1.swift.git", from: "0.16.0")
    ],
    targets: [
        .target(
            name: "Nostr", dependencies: [
                .product(name: "secp256k1", package: "secp256k1.swift")
            ]),
        .testTarget(
            name: "NostrTests",
            dependencies: ["Nostr"]),
    ]
)
