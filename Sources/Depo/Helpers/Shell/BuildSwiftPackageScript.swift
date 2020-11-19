//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

final class BuildSwiftPackageScript: ShellCommand {

    private let scriptPath: String = AppConfiguration.Path.Absolute.buildSPShellScript

    func callAsFunction(teamID: String, buildDir: String) -> Bool {
        shell(filePath: scriptPath, arguments: [teamID, buildDir])
    }
}
