//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-03-02.
//

import XCTest
@testable import EllipticCurveKit

private typealias KeyPair = EllipticCurveKit.KeyPair<Secp256k1>
private extension KeyPair {
    init() {
        self.init(private: .generateNew())
    }
}

final class ECIESTests: XCTestCase {
    
    private lazy var angelaMerkel   = KeyPair()
    private lazy var joeBiden       = KeyPair()
    private lazy var justinTrudeau   = KeyPair()
    
    private lazy var vladimirPutin  = KeyPair()
    
    let message = "Guten tag Joe! My nukes are 100 miles south west of Münich, don't tell anyone"
    
    static func makeECIES() -> ECIES {
        ECIES(symmetricKeyDerivationFunction: ECAddDiffieHellmanKDF())
    }
    
    let germany = makeECIES()
    let america = makeECIES()
    let russia = makeECIES()
    let canada = makeECIES()
    
    override func setUp() {
        XCTAssertAllInequal([
            angelaMerkel,
            joeBiden,
            justinTrudeau,
            vladimirPutin
        ])
    }
    
    
    /// Cyons suggestion - simple possible encryption still using ECIES
    ///
    /// Use a slightly modified ECIES, using Diffie-Hellman of sender and recipients public key as input. Modified ECIES as follows:
    /// Encryption (Alice with privateKey `a`): Instead of `S := (B * rG)`, we do: `S := (aBG + rG)`
    /// Decryption (Bob with privateKey `b`):   Instead of `S := (bG * R)`, we do: `S := (AbG + R)`
    ///
    /// # Assumptions:
    /// * Sender knows recipients public key, which she already does now,
    /// since a Radix Address contains recipients public key.
    ///
    /// # Disadvantages:
    /// * No third parties can decrypt (no "CC" as in email).
    ///
    /// # Advantages:
    /// * Both sender and recipient can decrypt
    /// * No additional encryption (meta) data needed so ECIES does not need to change
    /// * => simplest possible Atom.
    ///
    func testSimpleEncryptionSenderCanDecryptAsWell() throws {
        // 🇩🇪🇩🇪🇩🇪 In Germany 🇩🇪🇩🇪🇩🇪
        // Angela Merkel encrypts message for Joe Biden
        let sealedBox = try germany.encrypt(
            message: message,
            recipientPublicKey: joeBiden.publicKey,
            senderPrivateKey: angelaMerkel.privateKey
        )
        
        let decryptedByMerkel = try germany.decrypt(
            data: sealedBox.combined,
            alicePublicKey: joeBiden.publicKey,
            bobPrivateKey: angelaMerkel.privateKey
        )
        XCTAssertEqual(decryptedByMerkel, message)
        
        // 🇺🇸🇺🇸🇺🇸 In the US 🇺🇸🇺🇸🇺🇸
        // Joe Biden can indeed decrypt encrypted message from Angela
        let decryptedByBiden = try america.decrypt(
            data: sealedBox.combined,
            alicePublicKey: angelaMerkel.publicKey,
            bobPrivateKey: joeBiden.privateKey
        )
        XCTAssertEqual(decryptedByBiden, message)

        // 🇷🇺🇷🇺🇷🇺 In Russia 🇷🇺🇷🇺🇷🇺
        // Putin should not be able to decrypt the message
        Assert(vladimirPutin, cannotDecrypt: sealedBox.combined, encryptedBy: angelaMerkel.publicKey)
    }
}

private extension ECIESTests {
    func Assert(
        _ thirdParty: KeyPair,
        cannotDecrypt encryptedMessage: Data,
        encryptedBy encryptor: PublicKey<Secp256k1>,
        _ file: StaticString = #file,
        _ line: UInt = #line
    ) {
        XCTAssertThrowsSpecificError(
            file: file,
            line: line,
            try Self.makeECIES().decrypt(data: encryptedMessage, alicePublicKey: encryptor, bobPrivateKey: thirdParty.privateKey),
            ECIES.DecryptionError.symmetricDecryptionFailed(.authenticationFailure),
            "Third party should not be able to decode message intended for someone else"
        )
    }
}
