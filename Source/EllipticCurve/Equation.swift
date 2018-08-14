//
//  Equation.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-08-02.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol Equation {
    func isZero(point: Point) -> Bool
}

public protocol TwoDimensionalEquation: Equation {
    func isZero(point: TwoDimensionalPoint) -> Bool
    func isZero(x: Number, y: Number) -> Bool
    func solve(x: Number, y: Number) -> (lhs: Number, rhs: Number)
}

public protocol TwoDimensionalBalancedEquationRepresentable: TwoDimensionalEquation {
    func solveLHS(x: Number) -> Number
    func solveRHS(y: Number) -> Number
}

public protocol TwoDimensionalImbalancedEquationRepresentable: TwoDimensionalEquation {
    func solveLHS(x: Number, y: Number) -> Number
    func solveRHS(x: Number, y: Number) -> Number
}

extension Equation where Self: TwoDimensionalEquation {
    public func isZero(point: Point) -> Bool {
        guard let twoDimensionalPoint = point as? TwoDimensionalPoint else { return false }
        return isZero(point: twoDimensionalPoint)
    }
}

public extension TwoDimensionalEquation {
    func isZero(point: TwoDimensionalPoint) -> Bool {
        return isZero(x: point.x, y: point.y)
    }

    func isZero(x: Number, y: Number) -> Bool {
        let solved = solve(x: x, y: y)
        return solved.lhs == solved.rhs
    }
}

public extension TwoDimensionalBalancedEquationRepresentable {
    func solve(x: Number, y: Number) -> (lhs: Number, rhs: Number) {
        return (lhs: solveLHS(x: x), rhs: solveRHS(y: y))
    }
}

public extension TwoDimensionalImbalancedEquationRepresentable {
    func solve(x: Number, y: Number) -> (lhs: Number, rhs: Number) {
        return (lhs: solveLHS(x: x, y: y), rhs: solveRHS(x: x, y: y))
    }
}

extension Equation {
    typealias X = Number
    typealias Y = Number
    typealias Side = Number
}

/// `Two dimensional` means two variables, e.g. `x` and `y`, to some power.
/// `Balanced` means all x-terms are on one side and all y-terms are on the other side.
public struct TwoDimensionalBalancedEquation {
    private let _solveLHS: (X) -> Side
    private let _solveRHS: (Y) -> Side
    private let _yFromX: (X) -> [Y]

    init(lhs: @escaping (X) -> Side, rhs: @escaping (Y) -> Side, yFromX: @escaping (X) -> [Y]) {
        _solveLHS = lhs
        _solveRHS = rhs
        _yFromX = { x in
            func pointAtCurve(x: X, y: Y) -> Bool {
                return lhs(x) == rhs(y)
            }
            return yFromX(x).filter { pointAtCurve(x: x, y: $0) }
        }
    }
}

public extension TwoDimensionalBalancedEquation {
    func getYFrom(x: Number) -> [Number] {
        return _yFromX(x)
    }
}

// MARK: - TwoDimensionalBalancedEquationRepresentable
extension TwoDimensionalBalancedEquation: TwoDimensionalBalancedEquationRepresentable {}
public extension TwoDimensionalBalancedEquation {
    func solveLHS(x: Number) -> Number {
        return _solveLHS(x)
    }

    func solveRHS(y: Number) -> Number {
        return _solveRHS(y)
    }

}


/// `Two dimensional` means two variables, e.g. `x` and `y`, to some power.
/// `Imbalanced` means x-terms and y-terms can exist on both the left- and the right hand side.
public struct TwoDimensionalImbalancedEquation {
    private let _solveLHS: (X, Y) -> Side
    private let _solveRHS: (X, Y) -> Side

    init(lhs: @escaping (X, Y) -> Side, rhs: @escaping (X, Y) -> Side) {
        _solveLHS = lhs
        _solveRHS = rhs
    }
}

extension TwoDimensionalImbalancedEquation: TwoDimensionalImbalancedEquationRepresentable {}
public extension TwoDimensionalImbalancedEquation {
    func solveLHS(x: Number, y: Number) -> Number {
        return _solveLHS(x, y)
    }

    func solveRHS(x: Number, y: Number) -> Number {
        return _solveRHS(x, y)
    }
}
