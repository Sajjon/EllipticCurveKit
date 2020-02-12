//
//  SecureRandom.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-24.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import Security

public func securelyGenerateBytes(count: Int) throws -> [Byte] {
    var randomBytes = [UInt8](repeating: 0, count: count)
    let statusRaw = SecRandomCopyBytes(kSecRandomDefault, count, &randomBytes) as OSStatus
    let status = Status(status: statusRaw)
    guard status == .success else { throw status }
    return randomBytes
}
