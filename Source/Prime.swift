//
//  Prime.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-06-06.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

// Credits goes to:
// https://github.com/dankogai/swift-prime/blob/master/prime/prime.swift

#if os(Linux)
import Glibc
#else
import Darwin
#endif

private func handleEdgeCasesForMod<I: FixedWidthInteger & UnsignedInteger>(x: I, m: I) -> I? {
    guard m > 0 else { fatalError("modulo by zero") }
    if m == 1 { return 1 } // Trivial
    if m == 2 { return x & 1 }  // just odd or even
    return nil
}

public extension UInt64 {
    /// (x * y) mod m
    /// unlike naive x * y % m, this does not overflow.
    public static func mulmod(_ x: UInt64, _ y: UInt64, _ m: UInt64) -> UInt64 {
        if let edgeCase = handleEdgeCasesForMod(x: x, m: m) { return edgeCase }

        var a = x % m
        if a == 0 { return 0 }
        var b = y % m
        if b == 0 { return 0 }

        var r: UInt64 = 0
        while a > 0 {
            if a & 1 == 1 { r = (r &+ b) % m }
            a >>= 1
            b = (b << 1) % m
        }
        return r
    }
}

public extension UInt {

    /// (x * y) mod m without worring about overflow.
    public static func mulmod(_ x: UInt, _ y: UInt, _ m: UInt) -> UInt {
        let (xy, overflow) = x.multipliedReportingOverflow(by: y)
        return !overflow ? xy % m : UInt(UInt64.mulmod(UInt64(x),UInt64(y),UInt64(m)))
    }

    /// (x ** y) mod m
    public static func powmod(_ x: UInt, _ y: UInt, _ m: UInt) -> UInt {
        if let edgeCase = handleEdgeCasesForMod(x: x, m: m) { return edgeCase }

        var r: UInt = 1, t = x, n = y
        while n > 0 {
            if n & 1 == 1 { r = mulmod(r, t, m) }
            t = mulmod(t, t, m)
            n >>= 1
        }
        return r
    }

    /// Greatest Common Divisor
    public static func gcd(_ m: UInt, _ n: UInt) -> UInt {
        if n == 0 { return m }
        if m < n { return gcd(n, m) }
        let r = m % n
        return r == 0 ? n : gcd(n, r)
    }

    /// b ** x
    public static func ipow(_ b: UInt, _ x: UInt) -> UInt {
        var r: UInt = 1, t = b, n = x
        while n > 0 {   // &* is neccessary to avoid overflow exception
            if n & 1 == 1 {
                r = r &* t
            }
            n >>= 1; t = t &* t
        }
        return r
    }

    /// Integer Square Root of `n`
    public static func isqrt(_ n: UInt) -> UInt {
        var xk = UInt(sqrt(Double(n)))
        if xk <= 67108864 { return (xk)}  //sqrt(2^52)
        repeat {
            let xk1 = (xk + n / xk) / 2
            if xk1 >= xk { return xk }
            xk = xk1
        } while true
    }

    /// Integer Cube Root of `n`
    public static func icbrt(_ n: UInt) -> UInt {
        if n == 0 { return 0 }
        if n == 1 { return 1 }
        if n == UInt64.max {
            return 2642245 // floor(cbrt(2^64))
        }
        var xk = n
        repeat {
            let xk1 = (2*xk + n/xk/xk) / 3
            if xk1 >= xk { return xk }
            xk = xk1
        } while true
    }
}
public extension Int {

    /// (x * y) mod m without worring about overflow.
    public static func mulmod(_ x: Int, _ y: Int, _ m: Int) -> Int {
        let (ax, ay, am) = (abs(x),abs(y),abs(m))
        let sxy = 0 < x ? 0 < y ? 1 : -1 : 1
        return sxy * Int(UInt.mulmod(UInt(ax),UInt(ay),UInt(am)))
    }

    /// Greatest Common Divisor
    public static func gcd(_ m: Int, _ n: Int) -> Int {
        if m < 0 {
            return gcd(-m, n < 0 ? -n : n)
        }
        if n == 0 { return m }
        if m < n { return gcd(n, m) }
        let r = m % n
        return r == 0 ? n : gcd(n, r)
    }

    /// b ** x
    public static func ipow(_ b: Int, _ n: Int) -> Int {
        return Int(UInt.ipow(UInt(b), UInt(n)))
    }

    /// Integer Square Root of `n`
    public static func isqrt(_ n: Int) -> Int {
        return Int(UInt.isqrt(UInt(n)))
    }
}

public extension UInt {
    public class Prime: Sequence {
        public func makeIterator() -> PrimeIterator {
            return PrimeIterator(0)
        }

        public struct PrimeIterator: IteratorProtocol {
            var currPrime: UInt

            init(_ prime: UInt) {
                self.currPrime = prime
            }

            public mutating func next() -> UInt? {
                let nextPrime = currPrime.nextPrime
                if nextPrime > currPrime {
                    currPrime = nextPrime
                    return currPrime
                }
                return nil
            }
        }
    }
}

public extension UInt.Prime {

    /// primes less than 2048
    public static let tinyPrimes: [UInt] = {
        var ps:[UInt] = [2, 3]
        var n:UInt = 5
        while n < 2048 {
            for p in ps {
                if n % p == 0 { break }
                if p * p > n  { ps.append(n); break }
            }
            n += 2
        }
        return ps
    }()

    /// ### [A014233]
    ///
    /// Smallest odd number for which Miller-Rabin primality test
    /// on bases <= n-th prime does not reveal compositeness.
    ///
    /// [A014233]: https://oeis.org/A014233
    public static let A014233: [UInt] = [
        2047,                   // p0   = 2
        1373653,                // p1   = 3
        25326001,               // p2   = 5
        3215031751,             // p3   = 7
        2152302898747,          // p4   = 11
        3474749660383,          // p5   = 13
        341550071728321,        // p6   = 17
        341550071728321,        // p7   = 19
        3825123056546413051,    // p8   = 23
        3825123056546413051,    // p9   = 29
        3825123056546413051,    // p10  = 31
        0                       // p11  = 37; 318665857834031151167461  > UInt.max
    ]

    /// [Miller-Rabin] test `n` for `base`
    ///
    /// [Miller-Rabin]: https://en.wikipedia.org/wiki/Miller%E2%80%93Rabin_primality_test
    public class func millerRabinTest(_ n: UInt, base: UInt) -> Bool {
        if n < 2      { return false }
        if n & 1 == 0 { return n == 2 }
        var d = n - 1
        while d & 1 == 0 { d >>= 1 }
        var t:UInt = d
        var y = UInt.powmod(base, t, n)
        while t != n-1 && y != 1 && y != n-1 {
            y = UInt.mulmod(y, y, n)
            t <<= 1
        }
        return y == n-1 || t & 1 == 1
    }

    public class func isPrime(_ n: UInt) -> Bool {
        if n < 2      { return false }
        if n & 1 == 0 { return n == 2 }
        if n % 3 == 0 { return n == 3 }
        if n % 5 == 0 { return n == 5 }
        if n % 7 == 0 { return n == 7 }
        for i in 0..<A014233.count {
            // print("millerRabinTest(\(n), base:\(smallPrimes[i]))")
            if millerRabinTest(n, base:tinyPrimes[i]) == false { return false }
            if n < A014233[i] { break }
        }
        return true
    }

    public class func nextPrime(_ n: UInt) -> UInt {
        if n < 2 { return 2 }
        var u = n
        u += u & 1 == 0 ? 1 : 2
        while !isPrime(u) { u += 2 }
        return u
    }

    public class func prevPrime(_ n: UInt) -> UInt {
        if n < 2 { return 2 }
        var u = n
        u -= u & 1 == 0 ? 1 : 2
        while !isPrime(u) { u -= 2 }
        return u
    }

    public class func within(_ range: Range<UInt>) -> [UInt] {
        var result = [UInt]()
        var p = range.lowerBound
        if !p.isPrime { p = p.nextPrime }
        while p < range.upperBound {
            result.append(p)
            p = p.nextPrime
        }
        return result
    }

    /// Try to factor `n` by [Pollard's rho] algorithm
    ///
    /// [Pollard's rho]: https://en.wikipedia.org/wiki/Pollard%27s_rho_algorithm
    ///
    /// - parameter n: the number to factor
    /// - parameter l: the number of iterations
    /// - parameter c: seed
    public class func pollardsRho(_ n: UInt, _ l: UInt, _ c: UInt) -> UInt {
        //return UInt(c_pbrho(UInt64(n), UInt64(l), Int32(c)))
        var x:UInt = 2, y:UInt = 2, j:UInt = 2
        for i in 1...l {
            x = UInt.mulmod(x, x, n)
            x += c
            let d  = UInt.gcd(x < y ? y - x : x - y, n);
            if (d != 1) {
                return d == n ? 1 : d
            }
            if (i % j == 0) {
                y = x
                j += j
            }
        }
        return 1
    }

    // cf.
    //   http://en.wikipedia.org/wiki/Shanks'_square_forms_factorization
    //   https://github.com/danaj/Math-Prime-Util/blob/master/factor.c
    public static let squfofMultipliers: [UInt] = [
        1,      3,      5,      7,      11,
        3*5,    3*7,    3*11,   5*7,    5*11,
        7*11,   3*5*7,  3*5*11, 3*7*11, 5*7*11, 3*5*7*11
    ]

    /// Try to factor `n` by [SQUFOF] = Shanks' Square Forms Factorization
    ///
    /// [SQUFOF]: http://en.wikipedia.org/wiki/Shanks'_square_forms_factorization
    public class func squfof(_ n: UInt) -> UInt {
        let ks = squfofMultipliers.filter({ n < UInt(Int.max)/$0 }).reversed()
        // print("ks=\(ks)")
        for k in ks {
            if n.multipliedReportingOverflow(by: k).overflow { continue }
            //let g = UInt(c_squfof(UInt64(n), UInt64(k)))
            let g = squfof_one(n, k)
            // print("squof(\(n),\(k)) == \(g)")
            if g != 1 { return g }
        }
        return 1
    }

    public class func squfof_one(_ n: UInt, _ k: UInt) -> UInt {
        // print("n=\(n),k=\(k)")
        if n < 2      { return 1 }
        if n & 1 == 0 { return 2 }
        let rn = UInt.isqrt(n)
        if rn * rn == n { return rn }
        // if overflows just give up
        if n > UInt(Int.max) { return 1 }
        let kn = Int(k) &* Int(n)
        let rkn = Int.isqrt(kn)
        var p0 = rkn
        var q0 = 1
        var q1 = kn &- p0*p0
        var b0, b1, p1, q2 : Int
        for i in 0..<Int.isqrt(2 * rkn) {
            // print("Stage 1: p0=\(p0), q0=\(q0), q1=\(q1)")
            b1 = (rkn &+ p0) / q1
            p1 = b1 &* q1 &- p0
            q2 = q0 &+ b1 &* (p0 - p1)
            if i & 1 == 1 {
                let rq = Int.isqrt(q1)
                if rq * rq == q1 {
                    //  square root found; the algorithm cannot fail now.
                    b0 = (rkn &- p0) / rq
                    p0 = b0 &* rq &+ p0
                    q0 = rq
                    q1 = (kn &- p0*p0) / q0
                    while true {
                        // print("Stage 2: p0=\(p0), q0=\(q0), q1=\(q1)")
                        b1 = (rkn &+ p0) / q1
                        p1 = b1 &* q1 &- p0
                        q2 = q0 &+ b1 &* (p0 - p1)
                        if p0 == p1 {
                            return UInt.gcd(n, UInt(p1))
                        }
                        p0 = p1; q0 = q1; q1 = q2;
                    }
                }
            }
            p0 = p1; q0 = q1; q1 = q2
        }
        return 1
    }

    /// factor `u` and return prime facrors of it in array.
    ///
    /// axiom: `UInt.Prime.factor(u).reduce(1,*) == u` for any `u:UInt`
    ///
    /// It should succeed for all `u <= Int.max` but may fail for larger UInts.
    /// In which case `1` is prepended to the result so the axiom still holds.
    public class func factor(_ u: UInt) -> [UInt] {
        var n = u
        if n < 2 { return [n] }
        if isPrime(n) { return [n] }
        var result = [UInt]()
        for p in tinyPrimes[0..<83] {
            while n % p == 0 { result.append(p); n /= p }
            if n == 1 { return result }
        }
        if isPrime(n) { return result + [n] }
        if n < UInt(tinyPrimes.last! * tinyPrimes.last!) {
            for p in tinyPrimes[83..<tinyPrimes.count] {
                while n % p == 0 { result.append(p); n /= p }
                if n == 1 { return result }
            }
            if n != 1 { result.append(n) }
            return result
        }
        if isPrime(n) { return result + [n] }
        let l = Swift.min(UInt.isqrt(n), 0x1_0000)
        var d = pollardsRho(n, l, 1)
        if d == 1 {
            d = squfof(n)
        }
        result += d != 1 ? factor(d) + factor(n/d) : [1, n]
        result.sort(by: <)
        return result
    }
}

public extension UInt {
    /// true iff `self` is prime
    public var isPrime: Bool { return Prime.isPrime(self) }

    /// the next prime number to `self`
    public var nextPrime: UInt { return Prime.nextPrime(self) }

    /// the previous prime number from `self`
    public var prevPrime: UInt { return Prime.prevPrime(self) }

    /// the prime factors of `self`
    ///
    /// axiom: `i.primeFactors.reduce(1,*) == i` for any `i:Int`
    ///
    /// for negative integers, `-1` is appended to keep axiom.
    public var primeFactors: [UInt] { return Prime.factor(self) }
}

public extension Int {

    /// true iff `self` is prime
    public var isPrime: Bool {
        return self < 2 ? false : UInt(self).isPrime
    }

    /// the next prime number to `self`
    public var nextPrime: Int { return Int(UInt(self).nextPrime) }

    /// the previous prime number from `self`
    public var prevPrime: Int { return Int(UInt(self).prevPrime) }

    /// the prime factors of `self`
    ///
    /// axiom: `u.primeFactors.reduce(1,*) == u` for any `u:UInt`
    ///
    /// It may fail for `u > UInt(Int.max)`.
    /// In which case `1` is prepended to the result.
    public var primeFactors: [Int] {
        var result = UInt(abs(self)).primeFactors.map{ Int($0) }
        if self < 0 { result += [-1] }
        return result
    }
}

public extension Int {
    public class Prime: Sequence {
        public func makeIterator() -> PrimeIterator {
            return PrimeIterator(0)
        }

        public struct PrimeIterator: IteratorProtocol {
            var currPrime: Int

            init(_ prime: Int) {
                self.currPrime = prime
            }

            public mutating func next() -> Int? {
                guard currPrime < Int.max else { return nil }
                let nextPrime = currPrime.nextPrime
                if nextPrime > currPrime {
                    currPrime = nextPrime
                    return currPrime
                }
                return nil
            }
        }
    }
}

public extension Int.Prime {
    public class func within(range: Range<Int>) -> [Int] {
        let start = UInt(range.lowerBound)
        let startOrZero: UInt = Swift.max(0, start)
        let end   = UInt(range.upperBound)
        return UInt.Prime.within(startOrZero..<end).map{ Int($0) }
    }
}
