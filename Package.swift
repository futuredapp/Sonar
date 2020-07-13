// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Sonar",
    platforms: [.iOS(.v9), .tvOS(.v9)],
    products: [
        .library(name: "Sonar", targets: ["Sonar"])
    ],
    targets: [
        .target(name: "Sonar")
    ]
)
