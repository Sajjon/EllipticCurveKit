//
//  Macros.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2019-04-07.
//  Copyright © 2019 Alexander Cyon. All rights reserved.
//

import Foundation

internal func incorrectImplementation(_ reason: String?, _ file: String = #file, _ line: Int = #line) -> Never {
    let message: String
    let base = "Incorrect implementation, file: \(file), line: \(line)"
    if let reason = reason {
        message = "\(base), \(reason)"
    } else {
        message = base
    }
    fatalError(message)
}
