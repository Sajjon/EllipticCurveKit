//
//  Hasher.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-09-17.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

@testable import CryptoSwift

public protocol Hasher {
    var type: HashType { get }
    var digestLength: Int { get }
    var blockSize: Int { get }
    func digest() -> Data
    func calculate(_ data: Data) -> Data
}

public extension Hasher {
    func calculate(_ bytes: [Byte]) -> Data {
        return calculate(Data(bytes))
    }
}

extension Hasher where Self: CryptoSwift.DigestType {
    public func digest() -> Data {
        let one = calculate([])
        let two = calculate([])
        precondition(one == two)
        precondition(two == calculate([]))
        return Data(one)
    }
}

public protocol UpdatableHasher: Hasher, AnyObject {
    @discardableResult
    func update(_ data: Data) -> Self
}
public extension UpdatableHasher {
    @discardableResult
    func update(_ bytes: [Byte]) -> Self {
        return update(Data(bytes))
    }

    func newHasher() -> Self {
        return UpdatableHashProvider.hasher(variant: type) as! Self
    }
}

extension CryptoSwift.SHA2: UpdatableHasher {
    public func update(_ data: Data) -> CryptoSwift.SHA2 {
        _ = try! self.update(withBytes: data.bytes.slice, isLast: false)
        return self
    }

    public func calculate(for data: Data) -> Data {
        return update(data.bytes).digest()
    }


    public var type: HashType {
        switch variant {
        case .sha256: return HashType.sha2sha256
        default: fatalError("not supported yet")
        }
    }

    public func calculate(_ data: Data) -> Data {
        return Data(calculate(for: data.bytes))
    }
}

public final class UpdatableHashProvider {
    public static func hasher(variant: HashType) -> UpdatableHasher {
        switch variant {
        case .sha2sha256: return CryptoSwift.SHA2(variant: .sha256)
        }
    }
}


