//
//  Point.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-06-15.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct Point {
    public let x: Number
    public let y: Number
    public let isInfinity: Bool
    public init(x: Number, y: Number, isInfinity: Bool) {
        self.x = x
        self.y = y
    }
}
