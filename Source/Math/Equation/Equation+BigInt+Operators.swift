//
//  Equation+BigInt+Operators.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-08-31.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

import EquationKit
import BigInt

public func +(lhs: Atom, rhs: Atom) -> PolynomialType<BigInt> {
    return Polynomial(lhs).adding(other: Polynomial(rhs))
}

public func +(lhs: Atom, rhs: BigInt) -> PolynomialType<BigInt> {
    return Polynomial(lhs).adding(constant: rhs)
}

public func +(lhs: BigInt, rhs: Atom) -> PolynomialType<BigInt> {
    return Polynomial(rhs).adding(constant: lhs)
}

public func -(lhs: Atom, rhs: Atom) -> PolynomialType<BigInt> {
    return Polynomial(lhs).subtracting(other: Polynomial(rhs))
}

public func -(lhs: Atom, rhs: BigInt) -> PolynomialType<BigInt> {
    return Polynomial(lhs).subtracting(constant: rhs)
}

public func -(lhs: BigInt, rhs: Atom) -> PolynomialType<BigInt> {
    return Polynomial(rhs).negated().adding(constant: lhs)
}

public func *(lhs: Atom, rhs: Atom) -> PolynomialType<BigInt> {
    return Polynomial(lhs).multipliedBy(other: Polynomial(rhs))
}

public func *(lhs: Atom, rhs: BigInt) -> PolynomialType<BigInt> {
    return Polynomial(lhs).multipliedBy(constant: rhs)
}

public func *(lhs: BigInt, rhs: Atom) -> PolynomialType<BigInt> {
    return rhs * lhs
}

public func ^^(lhs: Atom, rhs: Int) -> PolynomialType<BigInt> {
    return Polynomial(lhs).raised(to: rhs)
}
