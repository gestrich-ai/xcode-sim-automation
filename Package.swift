// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "XCUITestControl",
    platforms: [.iOS(.v17), .macOS(.v15)],
    products: [
        .library(name: "XCUITestControl", targets: ["XCUITestControl"]),
        .library(name: "XCUITestControlModels", targets: ["XCUITestControlModels"]),
    ],
    targets: [
        .target(
            name: "XCUITestControlModels",
            path: "Sources/XCUITestControlModels"
        ),
        .target(
            name: "XCUITestControl",
            dependencies: ["XCUITestControlModels"],
            path: "Sources/XCUITestControl",
            linkerSettings: [.linkedFramework("XCTest")]
        ),
    ]
)
