// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Vimulator",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "Vimulator", targets: ["Vimulator"]),
    ],
    targets: [
        .target(name: "Vimulator"),
        .testTarget(name: "VimulatorTests", dependencies: ["Vimulator"]),
    ]
)
