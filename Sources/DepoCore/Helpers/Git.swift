//
// Copyright © 2021 Rosberry. All rights reserved.
//

import Foundation

public final class Git: ShellCommand {

    final class Remote: ShellCommand {

        var gitRemote: Self {
            self
        }

        public func add(name: String, url: URL) throws {
            let _: Int32 = try gitRemote("add \(name) \(url.absoluteString)")
        }

        public func callAsFunction() throws -> [String] {
            let output: String = try gitRemote("")
            return output.split(separator: Character("\n")).map { substring in
                String(substring)
            }
        }
    }

    var git: Self {
        self
    }
    private(set) lazy var remote: Remote = .init(commandPath: "\(commandPath) remote", shell: shell)
    static let masterBranchName: String = "master"
    static let defaultRemoteName: String = "origin"

    public convenience init() {
        self.init(commandPath: "git")
    }

    public func checkout(_ gitReference: String) throws {
        let _: Int32 = try git("checkout \(gitReference)")
    }

    public func createBranch(name: String) throws {
        let _: Int32 = try git("branch \(name) \(Self.masterBranchName)")
    }

    public func delete(branch: String) throws {
        let _: Int32 = try git("branch -D \(branch)")
    }

    public func delete(remoteBranch: String) throws {
        let _: Int32 = try git("push \(Self.defaultRemoteName) --delete \(remoteBranch)")
    }

    public func add(_ items: String) throws {
        let _: Int32 = try git("add \(items)")
    }

    public func commit(message: String) throws {
        let _: Int32 = try git("commit -m \"\(message)\"")
    }

    public func push(remote: String, branch: String) throws {
        let _: Int32 = try git("push \(remote) \(branch)")
    }

    public func currentBranch() throws -> String {
        let output: String = try git("rev-parse --abbrev-ref HEAD")
        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public func hasChanges() throws -> Bool {
        let output: String = try git("status -s")
        return !output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    public func initialize() throws {
        let _: Int32 = try git("init")
    }

    public func branches() throws -> [String] {
        let output: String = try git("show-ref --heads | cut -d/ -f3-")
        return output.lines
    }

    public func remoteBranches() throws -> [String] {
        let output: String = try git("ls-remote --heads --quiet | cut -d/ -f3-")
        return output.lines
    }

    public func clone(url: URL, to outputDirName: String = "", branchName: String) throws {
        let _: Int32 = try git("clone \(url.absoluteString) \(outputDirName) --branch=\(branchName) --depth=1 --single-branch")
    }
}
