// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "ECScrollView",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(name: "ECScrollView", targets: ["ECScrollView"])
    ],
    targets: [
        .target(name: "ECScrollView", dependencies: [], path: "Sources")
    ]
)
