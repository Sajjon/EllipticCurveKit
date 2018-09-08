import Foundation
import UIKit

// This does not work in Xcode 10, I get `error: Couldn't lookup symbols:`. Probably an xcode bug

/*
//@testable import EllipticCurveKit
import EllipticCurveKit


let privateKey = PrivateKey(hex: "B7E151628AED2A6ABF7158809CF4F3C762E7160F38B4DA56A784D9045190CFEF") {
let keyPair = AnyKeyGenerator<Secp256k1>.restoreKeyPairFrom(privateKey: privateKey, format: .raw)

// TEST VECTOR 2: https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki#test-vectors
let signature = Signature(hex: "2A298DACAE57395A15D0795DDBFD1DCB564DA82B0F269BC70A74F8220429BA1D1E51A22CCEC35599B8F266912281F8365FFC2D035A230434A1A64DC59F7013FD")

let message = Message(hex: "243F6A8885A308D313198A2E03707344A4093822299F31D0082EFA98EC4E6C89")


if AnyKeySigner<Schnorr<Secp256k1>>.verify(message, wasSignedBy: signature, using: keyPair) {
    print("'It's working, it's working!' - Anakin Skywaker ( https://youtu.be/AXwGVXD7qEQ )")
}

*/
