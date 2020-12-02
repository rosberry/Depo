//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore
import ArgumentParser

extension AllPackagesManager: CLIPackageManager {
    struct Options: HasDepofileExtension, ParsableArguments {
        @Option(name: [.customLong("depofile-extension"), .customShort(Character("e"))],
                help: "\(DataCoder.Kind.allFlagsHelp)")
        var depofileExtension: DataCoder.Kind = .defaultValue

        @Option(name: [.customLong("platform"), .customShort(Character("p"))],
                help: "\(Platform.allFlagsHelp)")
        var platform: Platform = .defaultValue

        @Option()
        var podCommandPath: String = AppConfiguration.Path.Absolute.podCommandPath

        @Option()
        var carthageCommandPath: String = AppConfiguration.Path.Absolute.carthageCommandPath

        @Option()
        var swiftCommandPath: String = AppConfiguration.Path.Absolute.swiftCommandPath
    }

    convenience init(depofile: Depofile, options: Options) {
        self.init(depofile: depofile,
                  platform: options.platform,
                  podCommandPath: options.podCommandPath,
                  carthageCommandPath: options.carthageCommandPath,
                  swiftCommandPath: options.swiftCommandPath)
    }
}