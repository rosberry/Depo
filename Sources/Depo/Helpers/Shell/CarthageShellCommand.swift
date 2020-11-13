//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser

final class CarthageShellCommand: ShellCommand {

    enum Error: LocalizedError {
        case badBootstrap
        case badUpdate
        case badBuild
    }

    enum BuildArgument {
        case platform(Platform)
        case cacheBuilds

        var arguments: [String] {
            switch self {
            case let .platform(platform):
                return platformArguments(platform: platform)
            case .cacheBuilds:
                return ["--cache builds"]
            }
        }

        func platformArguments(platform: Platform) -> [String] {
            switch platform {
            case .all:
                return []
            default:
                return ["--platform", platform.rawValue]
            }
        }
    }

    enum Platform: String, ExpressibleByArgument, HasDefaultValue, CaseIterable, RawRepresentable {

        case mac
        case ios
        case tvos
        case watchos
        case all

        static let defaultValue: CarthageShellCommand.Platform = .all
    }

    func update(arguments: [BuildArgument]) throws {
        try build(command: "update", arguments: arguments)
    }

    func bootstrap(arguments: [BuildArgument]) throws {
        try build(command: "bootstrap", arguments: arguments)
    }

    func build() throws {
         if !shell("carthage", "build") {
             throw Error.badBuild
         }
    }

    private func build(command: String, arguments: [BuildArgument]) throws {
        let args: [String] = ["carthage", command] + arguments.reduce([]) { result, arg in
            result + arg.arguments
        }
        if !shell(args) {
            throw Error.badUpdate
        }
    }
}
