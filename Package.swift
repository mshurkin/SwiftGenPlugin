// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftGenPlugin",
    products: [
        .plugin(name: "SwiftGen", targets: ["SwiftGen"]),
        .plugin(name: "SwiftGenPlugin", targets: ["SwiftGenPlugin"])
    ],
    targets: [
        .plugin(
            name: "SwiftGenPlugin",
            capability: .buildTool(),
            dependencies: ["swiftgen"]
        ),
        .plugin(
            name: "SwiftGen",
            capability: .command(
                intent: .custom(verb: "swiftgen", description: "Creates type-safe for all your resources"),
                permissions: [
                    .writeToPackageDirectory(reason: "This command generates source code")
                ]
            ),
            dependencies: ["swiftgen"]
        ),
        .binaryTarget(
            name: "swiftgen",
            url: "https://github.com/SwiftGen/SwiftGen/releases/download/6.6.2/swiftgen-6.6.2.artifactbundle.zip",
            checksum: "7586363e24edcf18c2da3ef90f379e9559c1453f48ef5e8fbc0b818fbbc3a045"
        )
    ]
)