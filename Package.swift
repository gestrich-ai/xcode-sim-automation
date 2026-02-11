// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "XCUITestControl",
    platforms: [.iOS(.v17), .macOS(.v15)],
    products: [
        .library(name: "XCUITestControl", targets: ["XCUITestControl"]),
    ],
    targets: [
        .target(
            name: "XCUITestControl",
            path: "Sources/XCUITestControl",
            linkerSettings: [.linkedFramework("XCTest")]
        ),
    ]
)
