//
//  Environment.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-09-02.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

var isRunningUnitTests: Bool {
    let env = ProcessInfo.processInfo.environment
    return env["TEST_MODE"] == "enable"
}
#if DEBUG
let isDebug = true
#else
let isDebug = false
#endif


var abstract: Never { fatalError("implement this in subclass") }
