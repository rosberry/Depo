//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public final class PodShellCommand: ShellCommand {

    private typealias Dependency = PodIpcJsonOutput.RootObject.Children.Dependency

    fileprivate struct PodIpcJsonOutput: Codable {

        private enum CodingKeys: String, CodingKey {
            case roots = "target_definitions"
        }

        let roots: [RootObject]
    }

    @discardableResult
    public func initialize() throws -> String {
        try shell(silent: "\(commandPath) init")
    }

    @discardableResult
    public func install(args: [String]) throws -> String {
        try shell(silent: "\(commandPath) install \(args.spaceJoined)")
    }

    @discardableResult
    public func update(args: [String]) throws -> String {
        try shell(silent: "\(commandPath) update \(args.spaceJoined)")
    }

    public func podfile(buildSettings: BuildSettings, podfilePath: String) throws -> PodFile {
        PodFile(buildSettings: buildSettings, pods: try pods(podfilePath: podfilePath))
    }

    public func pods(podfilePath: String) throws -> [Pod] {
        let output = try shell(silent: "\(commandPath) ipc podfile-json \(podfilePath)")
        let podfileJson = output.data(using: .utf8) ?? Data()
        let model = try JSONDecoder().decode(PodIpcJsonOutput.self, from: podfileJson)
        return pods(from: model)
    }

    private func pods(from jsonPodFile: PodIpcJsonOutput) -> [Pod] {
        let dependencies: [Dependency] = jsonPodFile.roots.flatMap { root -> [Dependency] in
            root.children.reduce([]) { result, child in
                result + child.dependencies
            }
        }
        return dependencies.compactMap { dependency -> Pod? in
            .init(name: dependency.name, versionConstraint: version(from: dependency.version))
        }
    }

    private func version(from string: String) -> VersionConstraint<Pod.Operator>? {
        let version = string.split(separator: .init(" "))
        guard version.count == 2,
              let `operator` = Pod.Operator(symbol: String(version[0])) else {
            return nil
        }
        return VersionConstraint<Pod.Operator>(operation: `operator`, value: String(version[1]))
    }
}

extension PodShellCommand.PodIpcJsonOutput {
    fileprivate struct RootObject: Codable {
        let name: String
        let children: [Children]
    }
}

extension PodShellCommand.PodIpcJsonOutput.RootObject {
    fileprivate struct Children: Codable {

        private enum CodingKeys: String, CodingKey {
            case name
            case dependencies
        }

        let name: String
        let dependencies: [Dependency]

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(String.self, forKey: .name)
            dependencies = try container.decodeIfPresent([Dependency].self, forKey: .dependencies) ?? []
        }
    }
}

extension PodShellCommand.PodIpcJsonOutput.RootObject.Children {
    fileprivate struct Dependency: Codable {
        let name: String
        let version: String

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let dict = try? container.decode([String: [String]].self) {
                self.name = dict.keys.first!
                self.version = dict.values.first![0]
            }
            else if let name = try? container.decode(String.self) {
                self.name = name
                self.version = ""
            }
            else {
                fatalError("cannot parse such Podfile")
            }
        }
    }
}
