//
//  Wallet.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-12.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct Wallet<Curve: EllipticCurve> {
    let keyPair: KeyPair<Curve>
    let publicAddress: PublicAddress<Curve>
}
