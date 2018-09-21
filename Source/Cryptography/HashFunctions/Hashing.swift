//
//  Hashing.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-09-21.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol Hashing {
    var function: HashFunction { get }
    var digestLength: Int { get }
    init(function: HashFunction)
    init?(name: String)
}

public extension Hashing {

    init?(name: String) {
        guard let function = HashFunction(name: name) else { return nil }
        self.init(function: function)
    }

    var digestLength: Int {
        return function.digestLength
    }
}
