//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

@_functionBuilder
struct ErrorsBuilder {
    static func buildBlock(_ partialResults: () throws -> Void...) -> [Error] {
        partialResults.compactMap { closure in
            do {
                try closure()
                return nil
            }
            catch {
                return error
            }
        }
    }
}

struct CompositeError: Error {

    let errors: [Error]

    @discardableResult
    init?(errors: [Error]) throws {
        guard !errors.isEmpty else {
            return nil
        }
        self.errors = errors
        throw self
    }

    @discardableResult
    init?(@ErrorsBuilder build: () -> [Error]) throws {
        try self.init(errors: build())
    }
}
