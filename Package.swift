// swift-tools-version: 6.3.3

import PackageDescription

let package = Package(
    name: "swift-rfc-8288",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
    ],
    products: [
        .library(name: "RFC 8288", targets: ["RFC 8288"])
    ],
    dependencies: [
        .package(path: "../../swift-primitives/swift-byte-primitives"),
        .package(path: "../../swift-primitives/swift-byte-parser-primitives"),
        .package(path: "../swift-rfc-3986"),
        .package(path: "../swift-rfc-9110"),
    ],
    targets: [
        .target(
            name: "RFC 8288",
            dependencies: [
                .product(name: "Byte Primitives", package: "swift-byte-primitives"),
                .product(
                    name: "Byte Primitives Standard Library Integration",
                    package: "swift-byte-primitives"
                ),
                .product(name: "Byte Parser Primitives", package: "swift-byte-parser-primitives"),
                .product(name: "RFC 3986", package: "swift-rfc-3986"),
                .product(name: "RFC 9110", package: "swift-rfc-9110"),
            ]
        ),
        .testTarget(
            name: "RFC 8288 Tests",
            dependencies: ["RFC 8288"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    target.swiftSettings = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
    ]
}
