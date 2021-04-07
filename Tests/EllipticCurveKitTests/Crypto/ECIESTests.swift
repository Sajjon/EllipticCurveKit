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
        fileprivate let privateKey: PrivateKey<Secp256k1>
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
    
    func testDecryptMessageEncryptedByThisLib() throws {
        let senderPubKey: PublicKey<Secp256k1> = "04DB4BFDF2B5CDAF06D83746D9C483C1DD0E2513B2F95A2AF176B7BCAC9733CD588FB3123601009C162881B1B3F024EFF9F07F7A1F5FCC0B1D811B19999A635FCA"
        let privateKey: PrivateKey<Secp256k1> = "4BA74772420949170E44338B5410B37C314BAD295FBE07C0D1A612A345E9E149"

        let encryptedMessage = Data(hex: "ee5c74e22e6f37a041c057920320a2fab2a78c18ea875c9699000a56bba4409da4ad617c41629be6ee30ccf6971117593f9091b54c4b7a782fc5a9cb768bcabb38c637ea20ae6efd9d7f60161f162cfe48e79e1db3cb3c802521e1bdea2be134ad0938ec52ec218a794e38b8f29620ff7e031e016eece8c477e14a6ccc188809e35023d07dd663fedff837")

        let ecies = ECIES()
        let decrypted = try ecies.decrypt(data: encryptedMessage, whitePublicKey: senderPubKey, blackPrivateKey: privateKey)
        
        XCTAssertEqual(decrypted, message)
    }
    
    func testLength() throws {
        let message = "The Legend of Zelda is a high fantasy action-adventure video game franchise created by Japanese game designers Shigeru Miyamoto and Takashi Tezuka. It is developed and published by Nintendo."
        let ecies = ECIES()
        let alice = KeyPair()
        let bob = KeyPair()
        let encryptedMessage = try ecies.encrypt(
            message: message,
            whitePublicKey: bob.publicKey,
            blackPrivateKey: alice.privateKey
        )
        let encryptedBytes = encryptedMessage.combined
        XCTAssertLessThanOrEqual(
            encryptedBytes.count,
            256
        )
        let decrypted = try ecies.decrypt(
            data: encryptedBytes,
            whitePublicKey: alice.publicKey,
            blackPrivateKey: bob.privateKey
        )
        XCTAssertEqual(
            decrypted,
            message
        )
    }
}

extension AffinePoint: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        try! self.init(hex: value)
    }
}

extension PublicKey: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        let point = AffinePoint<Curve>.init(stringLiteral: value)
        self.init(point: point)
    }
}

extension PrivateKey: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(hex: value)!
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
