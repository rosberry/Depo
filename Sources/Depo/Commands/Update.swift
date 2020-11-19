//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser

final class Update<Command: HasUpdateCommand>: ParsableCommand {

    static var configuration: CommandConfiguration {
        .init(commandName: "update")
    }

    @OptionGroup()
    var options: Command.Options

    func run() throws {
        let depofile = try Depofile(decoder: options.depofileExtension.decoder)
        try Command(depofile: depofile, options: options).update()
    }
}