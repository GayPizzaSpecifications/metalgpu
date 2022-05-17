// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "metalgpu",
    platforms: [
        .macOS(.v10_11)
    ],
    products: [
        .executable(name: "metalgpu", targets: ["metalgpu"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .target(
            name: "metalgpu",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Collections", package: "swift-collections")
            ]
        ),
    ]
)
