//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public final class Shell {

    public enum Error: Swift.Error {
        case failure(IO)
        case badStatusCode(Int32)
    }

    public struct IO {
        public let stdOut: String
        public let stdErr: String
        public let stdIn: String
        public let status: Int32
        public let command: [String]

        fileprivate init(stdOut: String, stdErr: String, stdIn: String, status: Int32, command: [String]) {
            self.stdOut = stdOut
            self.stdErr = stdErr
            self.stdIn = stdIn
            self.status = status
            self.command = command
        }
    }

    private var observer: ((State) -> Void)?

    public init() {
    }

    @discardableResult
    public func callAsFunction(_ command: String) throws -> Int32 {
        observer?(.start(command: [command]))
        let process = Process()
        process.launchPath = "/bin/zsh"
        process.arguments = ["-c", command]
        try process.run()
        process.waitUntilExit()
        let statusCode = process.terminationStatus
        if statusCode == 0 {
            return statusCode
        }
        else {
            throw Error.badStatusCode(statusCode)
        }
    }

    public func callAsFunction(_ command: String) throws -> IO {
        observer?(.start(command: [command]))
        let process = Process()
        process.launchPath = "/bin/zsh"
        process.arguments = ["-c", command]
        let shellIO = try output(of: process, command: [command])
        if shellIO.status == 0 {
            return shellIO
        }
        else {
            throw Error.failure(shellIO)
        }
    }

    private func output(of process: Process, command: [String]) throws -> IO {
        let stdOutPipe = Pipe()
        let stdErrPipe = Pipe()
        let stdInFileHandle = Pipe().fileHandleForReading
        process.standardOutput = stdOutPipe
        process.standardError = stdErrPipe
        process.standardInput = stdInFileHandle
        try process.run()
        process.waitUntilExit()
        let handlersStrings = [stdOutPipe.fileHandleForReading,
                               stdErrPipe.fileHandleForReading,
                               stdInFileHandle].map { handler -> String in
            let outputData = handler.readDataToEndOfFile()
            return String(data: outputData, encoding: .utf8) ?? ""
        }
        return IO(stdOut: handlersStrings[0],
                  stdErr: handlersStrings[1],
                  stdIn: handlersStrings[2],
                  status: process.terminationStatus,
                  command: command)
    }

    private func terminationStatus(of process: Process) -> Int32 {
        process.launch()
        process.waitUntilExit()
        return process.terminationStatus
    }
}

extension Shell: ProgressObservable {

    public enum State {
        case start(command: [String])
    }

    @discardableResult
    public func subscribe(_ observer: @escaping (State) -> Void) -> Self {
        self.observer = observer
        return self
    }
}

extension Shell: Codable {
    public convenience init(from decoder: Decoder) throws {
        self.init()
    }

    public func encode(to encoder: Encoder) throws {
    }
}

fileprivate extension Either where Left == FileHandle, Right == Pipe {
    var fileHandleForReading: FileHandle {
        either(left: { left in
            left
        }, right: { right in
            right.fileHandleForReading
        })
    }
}
