# swift-rfc-8288

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Parsing and construction of Web Linking (HTTP Link header) values per RFC 8288.

## Standard Reference

- **RFC**: 8288
- **Title**: Web Linking

## Installation

Add the package to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/swift-ietf/swift-rfc-8288.git", branch: "main")
]
```

Add the product to a target that needs it:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "RFC 8288", package: "swift-rfc-8288")
    ]
)
```

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
