// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "ActivityLabel",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "ActivityLabel",
            targets: ["ActivityLabel"]
        )
    ],
    targets: [
        .target(
            name: "ActivityLabel"
        ),
        .testTarget(
            name: "ActivityLabelTests",
            dependencies: ["ActivityLabel"]
        )
    ]
)
