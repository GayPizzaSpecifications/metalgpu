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
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "1.1.4")),
        .package(url: "https://github.com/apple/swift-collections", .upToNextMajor(from: "1.0.3"))
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
