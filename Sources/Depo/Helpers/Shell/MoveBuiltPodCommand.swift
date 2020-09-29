//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

final class MoveBuiltPodCommand: ShellCommand {

    private let scriptPath: String = AppConfiguration.moveBuiltPodShellFilePath

    func callAsFunction(pod: Pod) -> Bool {
        shell(filePath: scriptPath, arguments: [pod.name])
    }
}
