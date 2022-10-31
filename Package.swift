// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftGenPlugin",
    products: [
        .plugin(name: "SwiftGenBuildPlugin", targets: ["SwiftGenBuildPlugin"]),
        .plugin(name: "SwiftGenPlugin", targets: ["SwiftGenPlugin"])
    ],
    targets: [
        .plugin(
            name: "SwiftGenBuildPlugin",
            capability: .buildTool(),
            dependencies: ["swiftgen"]
        ),
        .plugin(
            name: "SwiftGenPlugin",
            capability: .command(
                intent: .custom(verb: "swiftgen", description: "Creates type-safe for all your resources"),
                permissions: [
                    .writeToPackageDirectory(reason: "This command generates source code")
                ]
            ),
            dependencies: ["swiftgen"]
        ),
        .binaryTarget(name: "swiftgen", path: "Binaries/swiftgen-6.6.2.artifactbundle.zip")
    ]
)
