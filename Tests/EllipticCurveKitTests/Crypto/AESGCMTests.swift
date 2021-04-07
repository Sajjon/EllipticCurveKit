//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-03-09.
//

import Foundation
import XCTest
@testable import EllipticCurveKit
import CryptoKit

final class AESGCMTests: XCTestCase {
    func testAESGCM() throws {

        
        let nonce = try AES.GCM.Nonce(
            data: Data(hex: "bf9e592c50183db30afff24d")
        )
        
        let ciphertext = Data(hex: "d2d309e9d7c9c5f5ca692b3e51e4f84670e8ee3dfce4d183389e6fcea2f46a707101e38a6aff1754e57c533b6bea0f620d5bac85ec9a2f86352111e2fc2879c839b6ae0d931c30364d5245bcad69")
        
        let authTag = Data(hex: "baa17313cf02d4f34d135c34643426c8")

        let sealedBox = try AES.GCM.SealedBox(
            nonce: nonce,
            ciphertext: ciphertext,
            tag: authTag
        )
        
        let symmetricKeyData = Data(hex: "fbe8c9f0dcbdbf52ee3038b18ca378255c35583bae12eb50151d7458d43dc3e1")
        
        let additionalAuthData = Data(hex: "03B7F98F3FB16527A8F779C326A7A57261F1341EAC191011F7A916D01D668F4549")
        
        let decrypted = try AES.GCM.open(
            sealedBox,
            using: .init(data: symmetricKeyData),
            authenticating: additionalAuthData
        )
        
        let plaintext = String(data: decrypted, encoding: .utf8)!
        XCTAssertEqual(plaintext, "Guten tag Joe! My nukes are 100 miles south west of Münich, don't tell anyone")
    }
    

}
    
