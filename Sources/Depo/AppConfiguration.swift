//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

enum AppConfiguration {
    static let configFileName: String = "Depofile"
    static let cartFileName: String = "Cartfile"
    static let podFileName: String = "Podfile"
    static let packageSwiftFileName: String = "Package.swift"
    static let podsOutputDirectoryName: String = "Pods/Build/iOS"
    static let podsDirectoryName: String = "Pods"
    static let packageSwiftDirectoryName: String = ".build/checkouts"
    static let packageSwiftBuildsDirectoryName: String = ".build/builds"
    static let packageSwiftOutputDirectoryName: String = "SPM/Build/iOS"
    static let buildPodShellScriptFilePath: String = "/usr/local/bin/build_pod.sh"
    static let buildSPShellScriptFilePath: String = "/usr/local/bin/build_swift_package.sh"
    static let mergePackageShellScriptFilePath: String = "/usr/local/bin/merge_package.sh"
    static let moveBuiltPodShellFilePath: String = "/usr/local/bin/move_built_pod.sh"
}
