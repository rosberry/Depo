//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser

struct Pod {

    private enum CodingKeys: String, CodingKey {
        case name
        case versionConstraint = "version"
    }

    enum Kind {
        case common
        case builtFramework
        case unknown
    }

    enum Operator: String, Codable, HasDefaultValue {
        case equal
        case greater
        case greaterOrEqual
        case lower
        case lowerOrEqual
        case compatible

        var symbol: String {
            switch self {
            case .equal:
                return "="
            case .greater:
                return ">"
            case .greaterOrEqual:
                return ">="
            case .lower:
                return "<"
            case .lowerOrEqual:
                return "<="
            case .compatible:
                return "~>"
            }
        }

        static let defaultValue: Operator = .equal
    }

    let name: String
    let versionConstraint: VersionConstraint<Operator>?
}

extension Pod: Codable {

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let slashCharacter = Character("/")
        name = try container.decode(String.self, forKey: .name).filter { character in
            character != slashCharacter
        }
        versionConstraint = try container.decodeIfPresent(VersionConstraint.self, forKey: .versionConstraint)
    }
}
