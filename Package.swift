// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-rfc-8288",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
    ],
    products: [
        .library(name: "RFC 8288", targets: ["RFC 8288"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-byte.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-3986.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-9110.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "RFC 8288",
            dependencies: [
                .product(name: "Byte", package: "swift-byte"),
                .product(
                    name: "Byte",
                    package: "swift-byte"
                ),
                .product(name: "RFC 3986", package: "swift-rfc-3986"),
                .product(name: "RFC 9110", package: "swift-rfc-9110"),
            ]
        ),
        .testTarget(
            name: "RFC 8288 Tests",
            dependencies: [
                "RFC 8288",
                .product(name: "RFC 3986", package: "swift-rfc-3986"),
                .product(name: "RFC 9110", package: "swift-rfc-9110"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
