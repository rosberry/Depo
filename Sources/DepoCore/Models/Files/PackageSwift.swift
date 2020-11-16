//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public struct PackageSwift: CustomStringConvertible {

    public let description: String

    public init(projectBuildSettings settings: BuildSettings, items: [SwiftPackage]) {
        let dependencies = items.map(Self.package).joined(separator: ",\n\(Self.tabs(9)) ")
        self.description = """
                           // swift-tools-version:\(settings.swiftVersion)

                           import PackageDescription

                           let package = Package(name: "\(settings.productName)",
                                                 products: [.library(name: "\(settings.productName)",
                                                                     targets: ["\(settings.targetName)"])],
                                                 dependencies: [\(dependencies)],
                                                 targets: [.target(name: "\(settings.productName)",
                                                                   dependencies: [])])

                           """
    }

    private static func package(_ package: SwiftPackage) -> String {
        let version = ".\(package.versionConstraint.operation.rawValue)(\"\(package.versionConstraint.value)\")"
        return ".package(name: \"\(package.name)\", url: \"\(package.url)\", \(version))"
    }

    private static func tabs(_ count: UInt, tabWidth: Int = 4) -> String {
        (0..<count).reduce("") { result, _ in
            result + Array(repeating: Character(" "), count: tabWidth)
        }
    }

}
