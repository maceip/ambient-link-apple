// swift-tools-version: 6.1
import PackageDescription

// AmbientLinkKit is the shared, UI-agnostic core for the Apple surfaces:
// relay client + models, the Foundation Models ("Siri AI") assistant, and the
// App Intents that expose sessions to Siri / Spotlight / Shortcuts.
//
// The visionOS frontend (App/AmbientLinkVision) imports this package from an
// Xcode app target. SwiftPM can't emit a visionOS .app bundle, so the app is an
// Xcode target that depends on this library — see README.

let package = Package(
    name: "AmbientLinkKit",
    platforms: [
        .visionOS(.v26),
        .iOS(.v26),
        .macOS(.v26),
        .watchOS(.v26),
    ],
    products: [
        .library(name: "AmbientLinkKit", targets: ["AmbientLinkKit"]),
    ],
    dependencies: [
        // Vendor-neutral core (Session/RelayClient/GlassLink/EphemeralBuffer/Throttle).
        // Local path dep — requires ambient-link-core checked out as a sibling repo.
        .package(path: "../ambient-link-core/core-apple"),
    ],
    targets: [
        .target(
            name: "AmbientLinkKit",
            dependencies: [
                .product(name: "AmbientLinkCore", package: "core-apple"),
            ]
        ),
        .testTarget(
            name: "AmbientLinkKitTests",
            dependencies: ["AmbientLinkKit"]
        ),
    ]
)
