//
//  SwiftGenCommand.swift
//
//  Created by Максим Шуркин on 26.10.2022.
//  Copyright © 2022 Maxim Shurkin
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation
import PackagePlugin

@main
struct SwiftGenCommand: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        let (targets, arguments) = parse(
            arguments: arguments,
            targets: context.package.targets.map(\.name)
        )
        let swiftgen = try context.tool(named: "swiftgen").path

        let packageConfig = configurationFile(at: context.package.directory)
        for target in context.package.targets {
            guard let target = target as? SourceModuleTarget, targets.contains(target.name) else {
                continue
            }

            let configuration = configurationFile(at: target.directory) ?? packageConfig
            let arguments = addConfiguration(configuration, to: arguments)
            let environment = [
                "PROJECT_DIR": context.package.directory.string,
                "TARGET_NAME": target.name,
                "PRODUCT_MODULE_NAME": target.moduleName
            ]
            try run(swiftgen, with: arguments, environment: environment)
        }
    }
}

private extension SwiftGenCommand {
    func parse(
        arguments: [String],
        targets allTargets: @autoclosure () -> [String]
    ) -> (targets: [String], arguments: [String]) {
        var extractor = ArgumentExtractor(arguments)
        var targets = extractor.extractOption(named: "target")
        var arguments = extractor.remainingArguments

        if targets.isEmpty {
            targets = allTargets()
        }
        if arguments.isEmpty {
            arguments = ["config", "run",]
        }

        return (targets, arguments)
    }

    func configurationFile(at path: Path) -> Path? {
        let path = path.appending("swiftgen.yml")
        guard FileManager.default.fileExists(atPath: path.string) else {
            return nil
        }
        return path
    }

    func addConfiguration(_ configuration: Path?, to arguments: [String]) -> [String] {
        arguments.contains("--config")
            ? arguments
            : arguments + ["--config", configuration?.string].compactMap { $0 }
    }

    func run(_ exec: Path, with arguments: [String], environment: [String: String]) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: exec.string)
        process.arguments = arguments
        process.environment = environment

        try process.run()
        process.waitUntilExit()

        if process.terminationReason != .exit || process.terminationStatus != 0 {
            let problem = "\(process.terminationReason):\(process.terminationStatus)"
            Diagnostics.error("swiftgen invocation failed: \(problem)")
        }
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension SwiftGenCommand: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        let (targets, arguments) = parse(
            arguments: arguments,
            targets: context.xcodeProject.targets.map(\.displayName)
        )
        let swiftlint = try context.tool(named: "swiftgen").path

        let configuration = configurationFile(at: context.xcodeProject.directory)
        let args = addConfiguration(configuration, to: arguments)
        for target in context.xcodeProject.targets {
            guard targets.contains(target.displayName) else {
                continue
            }

            let environment = [
                "PROJECT_DIR": context.xcodeProject.directory.string,
                "TARGET_NAME": target.displayName,
            ]
            try run(swiftlint, with: args, environment: environment)
        }
    }
}
#endif
