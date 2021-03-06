//
// Copyright © 2021 Rosberry. All rights reserved.
//

import Files
import Foundation

public protocol GitIdentifiablePackage {
    func packageID(xcodeVersion: XcodeBuild.Version?) -> GitCacher.PackageID
}

public struct GitCacher: Cacher {

    public struct PackageID: CustomStringConvertible, ExpressibleByStringLiteral, Equatable {

        public typealias StringLiteralType = String

        public let description: String

        public init(xbVersion: String?, name: String, version: String?) {
            let xbVersion = xbVersion.map { value in
                "\(value)/"
            } ?? ""
            let version = version.map { value in
                "/\(value)"
            } ?? ""
            self.init(stringLiteral: "\(xbVersion)\(name)\(version)")
        }

        public init(stringLiteral value: StringLiteralType) {
            description = value
        }
    }

    // MARK: copy paste
    public enum Error: Swift.Error {
        case unableToCheckoutOrCreate(branch: String)
        case multipleFrameworks(path: String)
        case multipleRemotes(path: String)
    }

    private let gitRepoURL: URL
    private let git: Git = .init()
    private let fileManager: FileManager = .default

    public init(gitRepoURL: URL) {
        self.gitRepoURL = gitRepoURL
    }

    public func setupRepository(at localURL: URL, remoteURL: URL?) throws {
        try fileManager.perform(atPath: localURL.path) {
            try git.initialize()
            try Folder.current.createFile(named: ".gitkeep")
            try git.add(".")
            try git.commit(message: "Initial commit")
            try addRemoteIfNeeded(url: remoteURL)
        }
    }

    public func packageIDS() throws -> [PackageID] {
        let uuid = UUID().uuidString
        defer {
            try? deleteFolder(name: uuid)
        }
        try git.clone(url: gitRepoURL, to: uuid, branchName: Git.masterBranchName)
        return try fileManager.perform(atPath: uuid) { () -> [String] in
            try git.remoteBranches()
        }.map { remoteBranch -> PackageID in
            PackageID(stringLiteral: remoteBranch)
        }
    }

    public func get(packageID: PackageID) throws -> URL {
        let id = packageID.description
        try? deleteFolder(name: id)
        try git.clone(url: gitRepoURL, to: packageID.description, branchName: packageID.description)
        return try fileManager.perform(atPath: "./\(packageID.description)") {
            Folder.current.url
        }
    }

    public func save(buildURLs: [URL], packageID: PackageID) throws {
        let id = packageID.description
        defer {
            try? deleteFolder(name: id)
        }
        try? deleteFolder(name: id)
        try git.clone(url: gitRepoURL, to: id, branchName: Git.masterBranchName)
        try fileManager.perform(atPath: id) {
            try git.createBranch(name: id)
            try git.checkout(id)
            try Folder.current.deleteContents()
            try copyToCurrent(urls: buildURLs)
            try throwIfNoChanges(packageID: packageID)
            try git.add(".")
            try git.commit(message: id)
            try pushIfPossible(packageID: packageID)
        }
    }

    public func update(buildURLs: [URL], packageID: PackageID) throws {
        let id = packageID.description
        defer {
            try? deleteFolder(name: id)
        }
        try? deleteFolder(name: id)
        try git.clone(url: gitRepoURL, to: id, branchName: id)
        try fileManager.perform(atPath: id) {
            try Folder.current.deleteContents()
            try copyToCurrent(urls: buildURLs)
            try throwIfNoChanges(packageID: packageID)
            try git.add(".")
            try git.commit(message: id)
            try pushIfPossible(packageID: packageID)
        }
    }

    public func delete(packageID: PackageID) throws {
        let id = packageID.description
        defer {
            try? deleteFolder(name: id)
        }
        try? deleteFolder(name: id)
        try git.clone(url: gitRepoURL, to: id, branchName: id)
        try fileManager.perform(atPath: id) {
            try git.delete(remoteBranch: id)
        }
    }

    private func copyToCurrent(urls: [URL]) throws {
        for url in urls {
            try copyToCurrent(url: url)
        }
    }

    private func copyToCurrent(url: URL) throws {
        let string = url.absoluteString
        let absolutePath = (string as NSString).isAbsolutePath ? string : Folder.current.path + string
        if let folder = try? Folder(path: absolutePath) {
            try folder.copy(to: Folder.current)
        }
        else {
            let file = try File(path: absolutePath)
            try file.copy(to: Folder.current)
        }
    }

    private func throwIfNoChanges(packageID: PackageID) throws {
        guard try git.hasChanges() else {
            throw CacherError.noChangesToSave(packageID: packageID)
        }
    }

    private func addRemoteIfNeeded(url: URL?) throws {
        guard let url = url else {
            return
        }
        try git.remote.add(name: Git.defaultRemoteName, url: url)
    }

    private func pushIfPossible(packageID: PackageID) throws {
        let remotes = try git.remote()
        guard let remote = remotes.first,
              remotes.count == 1 else {
            throw Error.multipleRemotes(path: fileManager.currentDirectoryPath)
        }
        try git.push(remote: remote, branch: packageID.description)
    }

    private func deleteFolder(name: String) throws {
        try Folder.current.subfolder(named: name).delete()
    }
}

fileprivate extension URL {
    var gitRepoName: String {
        let splitted = lastPathComponent.split(separator: ".")
        return splitted[0...(splitted.count - 2)].reduce("") { result, substring in
            result + substring
        }
    }
}
