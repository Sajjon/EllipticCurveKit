//
//  Data_Extension.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-09.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public extension Data {
    public init(_ byte: Byte) {
        self.init([byte])
    }

    static var empty: Data {
        return Data()
    }
}
