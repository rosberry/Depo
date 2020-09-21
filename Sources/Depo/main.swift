//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser

final class Depo: ParsableCommand {
    static let configuration: CommandConfiguration = .init(abstract: "Main",
                                                           version: "0.0",
                                                           subcommands: [Install.self,
                                                                         InstallPods.self,
                                                                         InstallCarthageItems.self,
                                                                         InstallSwiftPackages.self],
                                                           defaultSubcommand: Install.self)
}

Depo.main()
