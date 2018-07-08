import Foundation
@testable import SwiftCrypto

let number: Number = "0x29ee955feda1a85f87ed4004958479706ba6c71fc99a67697a9a13d9d08c618e"

let publicKey = publicKeyPoint(from: number)
print(publicKey.asHexString())
