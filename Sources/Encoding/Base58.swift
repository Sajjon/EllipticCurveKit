//
//  Base58.swift
//  ZilliqaSDK
//
//  Created by Alexander Cyon on 2018-06-30.
//
//  Copy paste from: https://github.com/kishikawakatsumi/BitcoinKit/blob/master/BitcoinKit/Encoding.swift
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import BigInt

/// String representation of a Base58 string which is impossible to instantiatie with invalid values.
public struct Base58String: DataConvertible, CharacterSetSpecifying, Equatable, ExpressibleByStringLiteral {
    
    public static var allowedCharacters = CharacterSet.base58
    
    public let value: String
    public init(validated unvalidated: String) {
        do {
            self.value = try Base58String.validateCharacters(in: unvalidated)
        } catch {
            fatalError("Passed unvalid string, error: \(error)")
        }
    }
}

// MARK: - From Unvalidated String
public extension Base58String {
    init(string unvalidated: String) throws {
        let validated = try Base58String.validateCharacters(in: unvalidated)
        self.init(validated: validated)
    }
}

// MARK: - ExpressibleByStringLiteral
public extension Base58String {
    init(stringLiteral value: String) {
        do {
            try self.init(string: value)
        } catch {
            fatalError("Passed bad string value, error: \(error)")
        }
    }
}


// MARK: - DataInitializable
public extension Base58String {
    
    init(data: Data) {
        let bytes = data.bytes
        var x = data.unsignedBigInteger
        let alphabet = String.base58Alphabet.toData()
        let radix = BigUInt(alphabet.count)
        
        var answer = [UInt8]()
        answer.reserveCapacity(bytes.count)
        
        while x > 0 {
            let (quotient, modulus) = x.quotientAndRemainder(dividingBy: radix)
            answer.append(alphabet[Int(modulus)])
            x = quotient
        }
        
        let prefix = Array(bytes.prefix(while: {$0 == 0})).map { _ in alphabet[0] }
        answer.append(contentsOf: prefix)
        answer.reverse()
        
        self.init(validated: String(data: answer.asData))
    }
}

// MARK: DataConvertible
public extension Base58String {
    var asData: Data {
        
        let alphabet = String.base58Alphabet.toData()
        let radix = BigUInt(alphabet.count)
        let byteString = [UInt8](value.utf8)
        
        var answer = BigUInt(0)
        var temp = BigUInt(1)
        for character in byteString.reversed() {
            guard let index = alphabet.firstIndex(of: character) else {
                incorrectImplementation("Should contain character")
            }
            answer += temp * BigUInt(index)
            temp *= radix
        }
        return byteString.prefix(while: { $0 == alphabet[0] }) + answer.serialize()
    }
}

public extension String {
    static var base58Alphabet: String {
        return "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    }
    func toData(encodingForced: String.Encoding = .default) -> Data {
        guard let encodedData = self.data(using: encodingForced) else {
            incorrectImplementation("Should always be able to encode string to data")
        }
        return encodedData
    }
    init(data: Data, encodingForced: String.Encoding = .default) {
        guard let string = String(data: data, encoding: encodingForced) else {
            incorrectImplementation("Should always be able to get string from data")
        }
        self = string
    }
}

public extension CharacterSet {
    static var base58: CharacterSet {
        return CharacterSet(charactersIn: .base58Alphabet)
    }
}

public protocol CharacterSetSpecifying {
    static var allowedCharacters: CharacterSet { get }
}

public extension CharacterSetSpecifying {
    var allowedCharacters: CharacterSet {
        return Self.allowedCharacters
    }
    
    static func isSupersetOfCharacters(in string: String) -> Bool {
        return allowedCharacters.isSuperset(of: CharacterSet(charactersIn: string))
    }
    
    static func disallowedCharacters(in string: String) -> String? {
        for char in string {
            for unicodeScalar in char.unicodeScalars {
                guard allowedCharacters.contains(unicodeScalar) else {
                    return String(unicodeScalar)
                }
            }
        }
        return nil
    }
    
    static func validateCharacters(in string: String) throws -> String {
        if let disallowed = disallowedCharacters(in: string) {
            throw CharacterSetError.invalidCharacters(expectedCharacters: allowedCharacters, butGot: disallowed)
        }
        return string
    }
}

public enum CharacterSetError: Swift.Error {
    case invalidCharacters(expectedCharacters: CharacterSet, butGot: String)
}

// MARK: - Integer
public extension DataConvertible {
    var unsignedBigInteger: BigUInt {
        return BigUInt(asData)
    }
}
