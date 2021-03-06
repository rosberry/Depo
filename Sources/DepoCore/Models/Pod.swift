//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser

public struct Pod {

    private enum CodingKeys: String, CodingKey {
        case name
        case versionConstraint = "version"
    }

    public enum Kind {
        case common
        case builtFramework
        case unknown
    }

    public enum Operator: String, Codable, HasDefaultValue, CaseIterable, Hashable {
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

        public static let defaultValue: Operator = .equal

        init?(symbol: String) {
            typealias Context = (this: Self, symbol: String)
            // swiftlint:disable:next unused_closure_parameter
            let contexts: [Context] = Self.allCases.map { `operator` in
                (this: `operator`, symbol: `operator`.symbol)
            }
            guard let selfContext = contexts.first(with: symbol, at: \.symbol) else {
                return nil
            }
            self = selfContext.this
        }
    }

    public init(name: String, versionConstraint: VersionConstraint<Operator>?) {
        self.name = name
        self.versionConstraint = versionConstraint
    }

    public let name: String
    public let versionConstraint: VersionConstraint<Operator>?
}

extension Pod: Codable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let slashCharacter = Character("/")
        name = try container.decode(String.self, forKey: .name).filter { character in
            character != slashCharacter
        }
        versionConstraint = try container.decodeIfPresent(VersionConstraint.self, forKey: .versionConstraint)
    }
}

extension Pod: Hashable {
}
