// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "ECScrollView",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(name: "ECScrollView", targets: ["ECScrollView"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/combine-schedulers", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "ECScrollView",
            dependencies: [
                .product(name: "CombineSchedulers", package: "combine-schedulers")
            ],
            path: "Sources"
        ),
        .testTarget(name: "ECScrollViewTests", dependencies: ["ECScrollView"], path: "Tests")
    ]
)
