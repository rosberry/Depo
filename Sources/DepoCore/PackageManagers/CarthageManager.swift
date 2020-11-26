//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public final class CarthageManager: ProgressObservable {

    public enum State {
        case updating
        case installing
        case building
        case creatingCartfile(path: String)
        case shell(state: Shell.State)
    }

    public enum Error: LocalizedError {
        case badCartfile(path: String)
    }

    private enum CodingKeys: String, CodingKey {
        case options
        case carthageItems
    }

    private let cartfileName: String = AppConfiguration.Name.cartfile

    private let carthageItems: [CarthageItem]
    private let platform: Platform
    private let shell: Shell = .init()
    private let carthageShellCommand: CarthageShellCommand
    private var observer: ((State) -> Void)?

    public init(depofile: Depofile, platform: Platform, carthageCommandPath: String) {
        self.carthageItems = depofile.carts
        self.platform = platform
        self.carthageShellCommand = .init(commandPath: carthageCommandPath, shell: shell)
        self.shell.subscribe { [weak self] state in
            self?.observer?(.shell(state: state))
        }
    }

    public func subscribe(_ observer: @escaping (State) -> Void) -> Self {
        self.observer = observer
        return self
    }

    public func update() throws {
        observer?(.updating)
        try createCartfile(at: "./\(cartfileName)", with: carthageItems)
        try carthageShellCommand.update(arguments: [.platform(platform)])
    }

    public func install() throws {
        observer?(.installing)
        try createCartfile(at: "./\(cartfileName)", with: carthageItems)
        try carthageShellCommand.bootstrap(arguments: [.platform(platform)])
    }

    public func build() throws {
        observer?(.building)
        try carthageShellCommand.build()
    }

    private func createCartfile(at cartfilePath: String, with items: [CarthageItem]) throws {
        observer?(.creatingCartfile(path: cartfilePath))
        let content = Cartfile(items: items).description.data(using: .utf8)
        if !FileManager.default.createFile(atPath: cartfilePath, contents: content) {
            throw Error.badCartfile(path: cartfilePath)
        }
    }
}
