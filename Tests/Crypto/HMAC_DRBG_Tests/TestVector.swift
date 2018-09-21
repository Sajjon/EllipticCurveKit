//
//  TestVector.swift
//  EllipticCurveKitTests
//
//  Created by Alexander Cyon on 2018-09-17.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

@testable import EllipticCurveKit

struct TestVector {
    let name: String
    let entropy: Data
    let nonce: Data
    let personalizationString: Data?
    let entropyInputReseed: Data?
    let additionalInputReseed: Data?
    let keyValueAfterInit: KeyValue?
    let generateCalls: [Generate]
    let expected: Data
}


extension TestVector: CustomStringConvertible {
    var description: String {
        return """
        name: \(name)
        entropy: \(entropy.toHexString())
        nonce: \(nonce.toHexString())
        pers: \(String(describing: personalizationString?.toHexString()))
        """
    }
}
