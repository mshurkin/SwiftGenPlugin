# SwiftGenPlugin

[![Swift 5.7](https://img.shields.io/badge/Swift-5.7-orange.svg)](https://developer.apple.com/swift/)
[![SPM Plugin](https://img.shields.io/badge/SPM-Plugin-brightgreen.svg)](https://swift.org/package-manager/)
[![License MIT](https://img.shields.io/github/license/mshurkin/SwiftGenPlugin)](https://opensource.org/licenses/MIT)

A Swift Package Manager Plugin for [SwiftGen](https://github.com/SwiftGen/SwiftGen/) that will run it before each build

SwiftGen has its own [implementation](https://github.com/SwiftGen/SwiftGenPlugin)

## Add to Package

Add the package as a dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/mshurkin/SwiftGenPlugin", from: "6.6.2"),
]
```

Then add `SwiftGenPlugin` plugin to your targets:

```swift
targets: [
    .target(
        name: "YOUR_TARGET",
        dependencies: [],
        plugins: [
            .plugin(name: "SwiftGenBuildPlugin", package: "SwiftGenPlugin")
        ]
    ),
```

## Add to Project

Add this package to your project dependencies. Select a target and open the `Build Phases` inspector. Open `Run Build Tool Plug-ins` and add `SwiftGenBuildPlugin` from the list.

## SwiftGen config

Plugin look for a `swiftgen.yml` configuration file in the root of your package (in the same folder as `Package.swift`) and in the target's folder. If files are found in both places, the file in the target's folder is preferred.

The paths in the configuration depend on where it is located:

1. Root configuration requires a full path to resources. You can set `${TARGET_NAME}` instead of a specific target name, such as `Sources/${TARGET_NAME}/Resources/en.lproj/Localizable.strings`
2. Target configuration requires a relative path to resources

## Author
[Maxim Shurkin](https://github.com/mshurkin)

## License
SwiftGenPlugin is released under the MIT license. See [LICENSE](LICENSE) file for more info.
