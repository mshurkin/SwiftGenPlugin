//
//  SwiftGenBuildTool.swift
//
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
struct SwiftGenBuiltTool: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        guard
            let configuration = configurationFile(project: context.package.directory, target: target.directory)
        else {
            Diagnostics.error("No SwiftGen configurations found for target \(target.name).")
            return []
        }

        clean(directory: context.pluginWorkDirectory)

        return [
            .prebuildCommand(
                displayName: "Run SwiftGen for \(target.name)",
                executable: try context.tool(named: "swiftgen").path,
                arguments: [
                    "config", "run",
                    "--verbose",
                    "--config", "\(configuration.string)"
                ],
                environment: [
                    "PROJECT_DIR": context.package.directory,
                    "TARGET_NAME": target.name,
                    "PRODUCT_MODULE_NAME": (target as? SourceModuleTarget)?.moduleName ?? "",
                    "DERIVED_SOURCES_DIR": context.pluginWorkDirectory
                ],
                outputFilesDirectory: context.pluginWorkDirectory
            )
        ]
    }
}

private extension SwiftGenBuiltTool {
    func configurationFile(project: Path, target: Path? = nil) -> Path? {
        [target, project]
            .compactMap { $0?.appending("swiftgen.yml") }
            .first { FileManager.default.fileExists(atPath: $0.string) }
    }

    func clean(directory: Path) {
        let fileManager = FileManager.default
        try? fileManager.removeItem(atPath: directory.string)
        try? fileManager.createDirectory(atPath: directory.string, withIntermediateDirectories: false)
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension SwiftGenBuiltTool: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
        guard let configuration = configurationFile(project: context.xcodeProject.directory) else {
            Diagnostics.error("No SwiftGen configurations found for project \(context.xcodeProject.displayName).")
            return []
        }

        clean(directory: context.pluginWorkDirectory)

        return [
            .prebuildCommand(
                displayName: "Run SwiftGen for \(target.displayName)",
                executable: try context.tool(named: "swiftgen").path,
                arguments: [
                    "config", "run",
                    "--verbose",
                    "--config", "\(configuration.string)"
                ],
                environment: [
                    "PROJECT_DIR": context.xcodeProject.directory,
                    "TARGET_NAME": target.displayName,
                    "DERIVED_SOURCES_DIR": context.pluginWorkDirectory
                ],
                outputFilesDirectory: context.pluginWorkDirectory
            )
        ]
    }
}
#endif
