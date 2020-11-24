//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public final class BuildSwiftPackageScript: ShellCommand {

    private let scriptPath: String = AppConfiguration.Path.Absolute.buildSPShellScript

    public func callAsFunction(teamID: String, buildDir: String, target: String) -> Bool {
        shell(filePath: scriptPath, arguments: [teamID, buildDir, target])
    }
}
