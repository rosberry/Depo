//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

extension DecodingError: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .typeMismatch(type, context):
            return "Got type mismatch while decoding \(type). \n\(context)"
        case let .valueNotFound(type, context):
            return "Value not found while decoding \(type). \n\(context)"
        case let .keyNotFound(key, context):
            return "Key \"\(key.stringValue)\" not found. \n\(context)"
        case let .dataCorrupted(context):
            return "Data corrupted. \n\(context)"
        @unknown default:
            return ""
        }
    }
}

extension DecodingError.Context: CustomStringConvertible {
    public var description: String {
        let codingPath = "codingPath: \(self.codingPath.map(by: \.stringValue).joined(separator: " <- "))"
        let underlyingError = self.underlyingError.map { "\nunderlyingError: \($0.localizedDescription)" } ?? ""
        return codingPath + underlyingError
    }
}
