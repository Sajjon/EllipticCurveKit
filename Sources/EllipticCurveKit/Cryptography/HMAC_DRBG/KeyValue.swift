//
//  KeyValue.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-09-17.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

/// Only for unit tests for HMAC DRBG
public struct KeyValue: Codable {
    enum CodingKeys: String, CodingKey {
        case v = "V"
        case key = "Key"
    }
    let v: String
    let key: String
}
