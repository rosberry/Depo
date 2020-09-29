//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser

final class Install: ParsableCommand {

    @OptionGroup()
    private var options: Options

    func run() throws {
        let depofile = try Depofile(decoder: options.depoFileType.decoder)
        try CompositeError {
            PodCommand(pods: depofile.pods).install
            CarthageCommand(carthageItems: depofile.carts).bootstrap
        }
    }
}
