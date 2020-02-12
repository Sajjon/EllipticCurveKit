//
//  NetworkInformation.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-24.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public typealias Byte = UInt8

public protocol NetworkInformation {
    var pubkeyhash: Byte { get }
    var privateKeyWifPrefix: Byte { get }
    var privateKeyWifSuffix: Byte { get }
}
