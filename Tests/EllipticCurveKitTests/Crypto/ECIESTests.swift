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
    
    public struct Country {
        public let headOfGovernment: String
        private let privateKey: PrivateKey<Secp256k1>
        public let publicKey: PublicKey<Secp256k1>

        private let ecies =  ECIES(symmetricKeyDerivationFunction: ECAddDiffieHellmanKDF())

        public init(headOfGovernment: String) {
            self.headOfGovernment = headOfGovernment
            let privateKey = PrivateKey<Secp256k1>.generateNew()
            self.privateKey = privateKey
            self.publicKey = PublicKey<Secp256k1>(privateKey: privateKey)
        }
        
        func encrypt(
            message: String,
            for country: Country
        ) throws -> Data {
            try encrypt(message: message, readableBy: country.publicKey)
        }
        
        func encrypt(
            message: String,
            readableBy whitePublicKey: PublicKey<Secp256k1>
        ) throws -> Data {
            try ecies.encrypt(
                message: message,
                whitePublicKey: whitePublicKey,
                blackPrivateKey: privateKey
            ).combined
        }
        
        func decrypt(
            encryptedMessage: Data,
            encryptedBy sender: Country
        ) throws -> String {
            try decrypt(encryptedMessage: encryptedMessage, encryptedBy: sender.publicKey)
        }
        
        func decrypt(
            encryptedMessage: Data,
            encryptedBy whitePublicKey: PublicKey<Secp256k1>
        ) throws -> String {
            try ecies.decrypt(
                data: encryptedMessage,
                whitePublicKey: whitePublicKey,
                blackPrivateKey: privateKey
            )
        }
    }
    
    let message = "Guten tag Joe! My nukes are 100 miles south west of Münich, don't tell anyone"
    
    
    let germany = Country(headOfGovernment: "Angela Merkel")
    let america = Country(headOfGovernment: "Joe Biden")
    let russia = Country(headOfGovernment: "Vladimir Putin")
    
    override func setUp() {
        XCTAssertAllInequal([
            germany.publicKey,
            america.publicKey,
            russia.publicKey
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
        let encryptedMessage = try germany.encrypt(message: message, for: america)
        try AssertThat(sender: germany, canOpenOwnMessage: encryptedMessage, sentTo: america)
        
        
        // 🇺🇸🇺🇸🇺🇸 In the US 🇺🇸🇺🇸🇺🇸
        // Joe Biden can indeed decrypt encrypted message from Angela
        let decryptedByBiden = try america.decrypt(
            encryptedMessage: encryptedMessage,
            encryptedBy: germany
        )
        XCTAssertEqual(decryptedByBiden, message)

        // 🇷🇺🇷🇺🇷🇺 In Russia 🇷🇺🇷🇺🇷🇺
        // Putin should not be able to decrypt the message
        AssertThat(thirdParty: russia, cannotDecrypt: encryptedMessage, sentBy: germany)
    }
}

private extension ECIESTests {
    func AssertThat(
        thirdParty: Country,
        cannotDecrypt encryptedMessage: Data,
        sentBy sender: Country,
        _ file: StaticString = #file,
        _ line: UInt = #line
    ) {
        XCTAssertThrowsSpecificError(
            file: file,
            line: line,
            try thirdParty.decrypt(
                encryptedMessage: encryptedMessage,
                encryptedBy: sender.publicKey
            ),
            ECIES.DecryptionError.symmetricDecryptionFailed(.authenticationFailure),
            "Third party should not be able to decode message intended for someone else"
        )
    }
    
    func AssertThat(
        sender: Country,
        canOpenOwnMessage encryptedMessage: Data,
        sentTo recipient: Country
    ) throws {
        let decryptedBySender = try sender.decrypt(
            encryptedMessage: encryptedMessage,
            encryptedBy: recipient.publicKey
        )
        XCTAssertEqual(decryptedBySender, message, "Sender should be able to decrypt her own ")
    }
}
