// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "metalgpu",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "metalgpu", targets: ["metalgpu"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "metalgpu",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
    ]
)
