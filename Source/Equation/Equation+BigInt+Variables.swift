//
//  Equation+BigInt+Variables.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-08-31.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

import EquationKit
import BigInt

public typealias Variable = VariableStruct<BigInt>
public typealias Constant = ConstantStruct<BigInt>
public typealias Polynomial = PolynomialType<BigInt>
public typealias Exponentiation = ExponentiationStruct<BigInt>
public typealias Term = TermStruct<Exponentiation>

public let 𝑥 = Variable("𝑥")
public let 𝑦 = Variable("𝑦")
public let 𝑎 = Variable("𝑎")
public let 𝑏 = Variable("𝑏")


public let 𝑥² = Exponentiation(𝑥, exponent: 2)
public let 𝑥³ = Exponentiation(𝑥, exponent: 3)
public let 𝑥⁴ = Exponentiation(𝑥, exponent: 4)
public let 𝑥⁵ = Exponentiation(𝑥, exponent: 5)
public let 𝑥⁶ = Exponentiation(𝑥, exponent: 6)
public let 𝑥⁷ = Exponentiation(𝑥, exponent: 7)
public let 𝑥⁸ = Exponentiation(𝑥, exponent: 8)
public let 𝑥⁹ = Exponentiation(𝑥, exponent: 9)

public let 𝑦² = Exponentiation(𝑦, exponent: 2)
public let 𝑦³ = Exponentiation(𝑦, exponent: 3)
public let 𝑦⁴ = Exponentiation(𝑦, exponent: 4)
public let 𝑦⁵ = Exponentiation(𝑦, exponent: 5)
public let 𝑦⁶ = Exponentiation(𝑦, exponent: 6)
public let 𝑦⁷ = Exponentiation(𝑦, exponent: 7)
public let 𝑦⁸ = Exponentiation(𝑦, exponent: 8)
public let 𝑦⁹ = Exponentiation(𝑦, exponent: 9)

public let 𝑎² = Exponentiation(𝑎, exponent: 2)
public let 𝑎³ = Exponentiation(𝑎, exponent: 3)

public let 𝑏² = Exponentiation(𝑏, exponent: 2)
public let 𝑏³ = Exponentiation(𝑏, exponent: 3)
