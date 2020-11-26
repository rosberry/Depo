//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

extension Array where Element == String {
    var spaceJoined: String {
        joined(separator: " ")
    }

    var newLineJoined: String {
        joined(separator: "\n")
    }
}
