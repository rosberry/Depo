//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Yams
import ArgumentParser

struct DataDecoder: TopLevelDecoder {
    typealias Input = Data

    enum Kind: String, Codable, RawRepresentable, CaseIterable, HasDefaultValue, ExpressibleByArgument {
        case json
        case yaml

        var decoder: DataDecoder {
            .init(kind: self)
        }

        static let defaultValue: Kind = .yaml
    }

    private let kind: Kind

    init(kind: Kind) {
        self.kind = kind
    }

    func decode<T>(_ type: T.Type, from input: Input) throws -> T where T: Decodable {
        switch kind {
        case .json:
            return try JSONDecoder().decode(type, from: input)
        case .yaml:
            return try YAMLDecoder().decode(type, from: input)
        }
    }
}
