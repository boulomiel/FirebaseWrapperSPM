// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FirebaseWrapperSPM",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "FirebaseWrapperSPM",
            targets: ["FirebaseWrapperSPM"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "Firebase",
                   url: "https://github.com/firebase/firebase-ios-sdk.git",
                   from: "8.0.0"),
        .package(url: "https://github.com/firebase/FirebaseUI-iOS.git", branch: "master"),
         

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "FirebaseWrapperSPM",
            dependencies: [
                    .product(name: "FirebaseDatabase", package: "Firebase"),
                    .product(name: "FirebaseFirestore", package: "Firebase"),
                    .product(name: "FirebaseStorage", package: "Firebase"),
                    .product(name: "FirebaseStorageUI", package: "FirebaseUI-iOS"),
                    .product(name: "FirebaseDatabaseUI", package: "FirebaseUI-iOS"),
                    .product(name: "FirebaseFirestoreUI", package: "FirebaseUI-iOS"),

            ]),
        .testTarget(
            name: "FirebaseWrapperSPMTests",
            dependencies: ["FirebaseWrapperSPM"]),
    ]
)


