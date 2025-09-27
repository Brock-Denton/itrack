// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "iTrack",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "iTrack",
            targets: ["iTrack"]),
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift", from: "2.0.0"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "iTrack",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS")
            ]),
        .testTarget(
            name: "iTrackTests",
            dependencies: ["iTrack"]),
    ]
)
