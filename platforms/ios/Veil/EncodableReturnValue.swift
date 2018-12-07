//
//  Copyright © 2018 Salesforce.com, inc. All rights reserved.
//

import Foundation

/**
 A wrapper for `Encodable` value types since `JSONEncoder` does not
 currently support top-level fragments.

 Once `JSONEncoder` supports encoding top-level fragments this can
 be removed.
 */
enum EncodableReturnType: Encodable {
    case void
    case value(Encodable)

    enum Keys: String, CodingKey {
        case v
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        switch self {
        case .void:
            try container.encodeNil(forKey: .v)
        case .value(let value):
            let superContainer = container.superEncoder(forKey: .v)
            try value.encode(to: superContainer)
        }

    }
}
