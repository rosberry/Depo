//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Files

public final class BuildSwiftPackageScript: ShellCommand {

    public typealias BuildContext = (scheme: String, settings: BuildSettings)

    private var xcodebuild: XcodeBuild {
        .init(shell: shell)
    }

    private let swiftPackageCommand: SwiftPackageShellCommand

    public init(swiftPackageCommand: SwiftPackageShellCommand, shell: Shell) {
        self.swiftPackageCommand = swiftPackageCommand
        super.init(commandPath: "", shell: shell)
    }

    public required init(from decoder: Decoder) throws {
        fatalError(#file + "\(#line)" + #function)
    }

    @discardableResult
    public func callAsFunction(like frameworkKind: MergePackage.FrameworkKind,
                               context: BuildContext,
                               buildDir: String) throws -> [String] {
        let (scheme, _) = context
        let derivedDataPath = "build"
        let config = XcodeBuild.Configuration.release
        let xcodebuildOutputs = try build(like: frameworkKind,
                                          scheme: scheme,
                                          derivedDataPath: derivedDataPath,
                                          config: config)
        try moveSwiftPackageBuildProductsToRightPlace(buildDir: buildDir,
                                                      config: config,
                                                      derivedDataPath: derivedDataPath)
        return xcodebuildOutputs
    }

    @discardableResult
    func generateXcodeprojectIfNeeded() throws -> String? {
        if xcodeprojects().isEmpty {
            return try swiftPackageCommand.generateXcodeproj()
        }
        else {
            return nil
        }
    }

    @discardableResult
    func deleteXcodeprojectIfCreated(creationOutput: String?) throws {
        guard creationOutput != nil else {
            return
        }
        for xcodeproject in xcodeprojects() {
            try xcodeproject.delete()
        }
    }

    private func xcodeprojects() -> [Folder] {
        Folder.current.subfolders.filter(by: AppConfiguration.xcodeProjectExtension, at: \.extension)
    }

    private func build(like frameworkKind: MergePackage.FrameworkKind,
                       scheme: String,
                       derivedDataPath: String,
                       config: XcodeBuild.Configuration) throws -> [String] {
        let xcodebuild = self.xcodebuild
        switch frameworkKind {
        case .fatFramework:
            return [try xcodebuild(settings: .device(scheme: scheme, configuration: config, derivedDataPath: derivedDataPath)),
                    try xcodebuild(settings: .simulator(scheme: scheme, configuration: config, derivedDataPath: derivedDataPath))]
        case .xcframework:
            return [try xcodebuild.buildForDistribution(settings: .device(scheme: scheme,
                                                                          configuration: config,
                                                                          derivedDataPath: derivedDataPath)),
                    try xcodebuild.buildForDistribution(settings: .simulator(scheme: scheme,
                                                                             configuration: config,
                                                                             derivedDataPath: derivedDataPath))]
        }
    }

    private func moveSwiftPackageBuildProductsToRightPlace(buildDir: String,
                                                           config: XcodeBuild.Configuration,
                                                           derivedDataPath: String) throws {
        let rightPlacePath = "\(buildDir)/\(Folder.current.name)/\(config.rawValue)"
        let deviceProductsRightPlaceFolder = try Folder.root.createSubfolderIfNeeded(at: "\(rightPlacePath)-iphoneos")
        let simulatorProductsRightPlaceFolder = try Folder.root.createSubfolderIfNeeded(at: "\(rightPlacePath)-iphonesimulator")

        let productsPath = "\(derivedDataPath)/Build/Products/\(config.rawValue)"
        let deviceProductsFolder = try Folder.current.subfolder(at: "\(productsPath)-iphoneos")
        let simulatorProductsFolder = try Folder.current.subfolder(at: "\(productsPath)-iphonesimulator")

        try deviceProductsRightPlaceFolder.deleteContents()
        try simulatorProductsRightPlaceFolder.deleteContents()
        try deviceProductsFolder.copyContents(to: deviceProductsRightPlaceFolder)
        try simulatorProductsFolder.copyContents(to: simulatorProductsRightPlaceFolder)
    }
}
