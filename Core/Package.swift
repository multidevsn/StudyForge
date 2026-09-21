// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "StudyForgeCore",
    platforms: [.macOS(.v13)],
    products: [.library(name: "StudyForge", targets: ["StudyForge"])],
    targets: [
        .target(name: "StudyForge"),
        .testTarget(name: "StudyForgeTests", dependencies: ["StudyForge"])
    ]
)
