//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import Files
import DepoCore

final class Init: ParsableCommand {

    struct Options: ParsableArguments {

        @Argument(help: "use relative paths")
        var filePaths: [String] = []

        @Option()
        var podCommandPath: String = AppConfiguration.Path.Absolute.podCommandPath

        @Option()
        var carthageCommandPath: String = AppConfiguration.Path.Absolute.carthageCommandPath

        @Option()
        var swiftCommandPath: String = AppConfiguration.Path.Absolute.swiftCommandPath
    }

    @OptionGroup()
    var options: Options

    func run() throws {
        let initService = InitService(podCommandPath: options.podCommandPath,
                                      carthageCommandPath: options.carthageCommandPath,
                                      swiftCommandPath: options.swiftCommandPath)
        initService.subscribe { state in
            print(state)
        }
        try initService.process(filePaths: options.filePaths)
    }
}
