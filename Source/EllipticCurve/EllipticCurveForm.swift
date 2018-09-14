//
//  EllipticCurveForm.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-27.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

/// Based on Ed Dawson:
/// PDF: https://pdfs.semanticscholar.org/presentation/9ebd/4d864ce5597eca5d2cb5021b7b5b0def4480.pdf
/// Youtube:  https://youtu.be/oiqueKI1Cvk?t=8m39s
///
/// For when talking about point artithmetic later on
/// M = "Multiplication"
/// S = "Squaring"
/// I = "Inversion" (most expensive, see below)
/// D = "Multiplication by a curve constant"
///
/// computation time complexity analysys and relationships:
/// S = 𝟘.𝟠M ("S costs 𝟘.𝟠 of the cost of M")
/// D = 𝟘.𝟚𝟝M
/// I = 𝟙𝟘𝟘M (EXPENSIVE!)
///
/// Scalars for curves are in the ring ℤ𝗉 (mod P), i.e. of the finite field GF, where the characteristics of the field GF (written `char(GF)` or `ch(GF)`) not equals 𝟚 and not equals 𝟛 (ch(GF)≠𝟚 and ch(GF)≠𝟛).
/// The Characteristics of a field: "is defined to be the smallest number of times one must use the ring's multiplicative identity (𝟙) in a sum to get the additive identity (𝟘)", ref: https://en.wikipedia.org/wiki/Characteristic_(algebra)
/// REQUIREMENTS
/// P is prime, P > 𝟛
/// 𝟜A³ + 𝟚𝟟B² (mod P) ≠ 𝟘
/// Reminder of Greek Alphabet:
///
/// `𝜓` reads out "psi"
/// `𝜑` reads out "phi"
/// Notation: `𝐸𝖰 ⟶ 𝐸𝖶, (𝑥, 𝑦)` describes a mapping from "𝐸𝖰" to "𝐸𝖶", which are two different forms of the same field.
public enum EllipticCurveForm {

    ///
    /// Weierstrass form (`𝑊`) of a curve.
    /// - Not used, see `shortWeierstrass` instead.
    ///
    ///
    /// # Equation
    ///     𝑊: 𝑌² + 𝑎₁𝑋𝑌 + 𝑎₃𝑌 = 𝑋³ + 𝑎₂𝑋² + 𝑎₄𝑋 + 𝑎₆
    ///
    /// [Ref: Stanford](https://crypto.stanford.edu/pbc/notes/elliptic/weier.html)
    ///
    case weierstrass

    ///
    /// Short Weierstrass form (`𝑆`) of a curve.
    /// - Covers all elliptic curves char≠𝟚,𝟛
    /// - Mixed Jacobian coordinates have been the speed leader for a long time.
    ///
    ///
    /// # Equation
    ///      𝑆: 𝑦² = 𝑥³ + 𝐴𝑥 + 𝐵
    ///
    case shortWeierstrass

    ///
    /// Extended Jacobi Quartic form (`𝑄`) of a curve.
    /// - Covers all elliptic curves with point of order 𝟚, char≠𝟚
    /// - Group operation speed using mixed coordinates:
    ///   - Double: 𝟚M + 𝟜S
    ///   - Add: 𝟞M + 𝟜S
    /// - Anno 2010: best form for "doubling intensive operations"
    ///
    ///
    /// # Equation
    ///     𝑄: 𝑦² = 𝑑𝑥⁴ + 𝟚𝑎𝑥² + 𝟙
    ///
    /// # 𝑄 is birationally equivalent to Weierstrass form:
    ///     𝑊: 𝑣² = 𝑢³ - 𝟜𝑎𝑢² + (𝟜𝑎² - 𝟜𝑑)𝑢
    ///
    /// # Mappings to Weierstrass form:
    ///     𝜓: 𝐸𝖰 ⟶ 𝐸𝖶, (𝑥, 𝑦) ⟼ ( (𝟚𝑦+𝟚)𝑥⁻² + 𝟚𝑎, (𝟚𝑦+𝟚)𝟚𝑥⁻³ + 𝟚𝑎*𝟚𝑥⁻¹ )
    ///
    ///     ⇔ substitution: { 🐶 = 𝟚𝑦+𝟚, 🐱 = 𝑥⁻², 🐭 = 𝟚𝑎, 🐹 = 𝟚𝑥⁻¹ } ⇔
    ///
    ///     𝜓: 𝐸𝖰 ⟶ 𝐸𝖶, (𝑥, 𝑦) ⟼ ( 🐱🐶 + 🐭, 🐹🐱🐶 + 🐭🐹)
    ///
    /// # Mappings to Extended Jacobi Quartic form:
    ///     𝜑: 𝐸𝖶 ⟶ 𝐸𝖰, (𝑢, 𝑣) ⟼ ( 𝟚𝑢𝑣⁻¹, (𝑢-𝟚𝑎)𝑢²𝟚𝑣⁻² - 𝟙 )
    ///
    case extendedJacobiQuartic

    ///
    /// Twisted Hessian form (`𝐻`) of a curve.
    /// - Covers all elliptic curves with a point of order 𝟛.
    /// - Group operation speed using mixed coordinates:
    ///   - Double: 𝟛M + 𝟞S
    ///   - Add: 𝟞M + 𝟞S
    ///
    ///
    /// # Equation
    ///     𝐻: 𝑎𝑥³ = 𝑦³ + 𝟙 = 𝑑𝑥𝑦
    ///
    ///
    /// # 𝐻 is birationally equivalent to Weierstrass form:
    ///     𝑊: 𝑣² = 𝑢³ - (𝑑⁴+𝟚𝟙𝟞𝑑𝑎)𝟜𝟠⁻¹𝑢 + (𝑑⁶-𝟝𝟜𝟘𝑑³𝑎-𝟝𝟠𝟛𝟚𝑎²)𝟠𝟞𝟜⁻¹
    ///
    ///
    /// # Mappings to Weierstrass form:
    ///     𝜓: 𝐸𝐻 ⟶ 𝐸𝑊, (𝑥, 𝑦) ⟼ ( ((𝑑³-𝟚𝟟𝑎)𝑥)/(𝟛(𝟛+𝟛𝑦+𝑑𝑥)) - 𝑑²/𝟜, ((𝑑³-𝟚𝟟𝑎)(𝟙-𝑦))/(𝟚(𝟛+𝟛𝑦+𝑑𝑥)) )
    ///
    ///     ⇔ substitution: { 🐶 = 𝑑³-𝟚𝟟𝑎, 🐱 = 𝟛+𝟛𝑦+𝑑𝑥 } ⇔
    ///
    ///     𝜓: 𝐸𝐻 ⟶ 𝐸𝖶, (𝑥, 𝑦) ⟼ (𝑥🐶(𝟛🐱)⁻¹ - 𝑑²/𝟜, (𝟙-𝑦)🐶(𝟚🐱)⁻¹ )
    ///
    ///
    /// # Mappings to Twisted Hessian form:
    ///     𝜑: 𝐸𝖶 ⟶ 𝐸𝐻, (𝑢, 𝑣) ⟼ ( (𝟙𝟠𝑑²+𝟟𝟚𝑢)/(𝑑³-𝟙𝟚𝑑𝑢-𝟙𝟘𝟠𝑎+𝟚𝟜𝑣), 𝟙-𝟜𝟠𝑣/(𝑑³-𝟙𝟚𝑑𝑢-𝟙𝟘𝟠𝑎+𝟚𝟜𝑣) )
    ///
    ///     ⇔ substitution: { 🐶 = (𝑑³-𝟙𝟚𝑑𝑢-𝟙𝟘𝟠𝑎+𝟚𝟜𝑣)⁻¹ } ⇔
    ///
    ///     𝜑: 𝐸𝖶 ⟶ 𝐸𝐻, (𝑢, 𝑣) ⟼ ( (𝟙𝟠(𝑑²+𝟜𝑢)🐶, (𝟙-𝟜𝟠𝑣)🐶 )
    ///
    case twistedHessian

    ///
    /// Twisted Edwards form (`𝐸`) of a curve.
    /// - Covers all elliptic curve covered by Montgomery curves: `𝑏𝑦² = 𝑥³ + 𝑎𝑥² + 𝑥`
    /// - Group operation speed using mixed coordinates:
    ///   - Double: 𝟛M+𝟜S
    ///   - Add: 𝟠M
    /// - Currently best for addition intensive operations, very interesting for parallell implementations (Apple Metal𝟚 on GPU?)
    ///
    ///
    /// # Equation
    ///     𝐸: 𝑎𝑥² + 𝑦² = 𝟙 + 𝑑x²𝑑𝑦²
    ///
    ///
    /// # 𝐸 is birationally equivalent to Weierstrass form:
    ///     𝑊: 𝑣² = 𝑢³ + 𝟚(𝑎+𝑑)𝑢² + (𝑎-𝑑)²𝑢
    ///
    ///
    /// # Mappings to Weierstrass form:
    ///     𝜓: 𝐸𝐸 ⟶ 𝐸𝑊, (𝑥, 𝑦) ⟼ ( (𝟙+𝑦)²(𝟙-𝑑𝑥²)/𝑥², 𝟚(𝟙+𝑦)²(𝟙-𝑑𝑥²)/𝑥³ )
    ///
    ///     ⇔ substitution: { 🐶 = (𝟙+𝑦)², 🐱 = 𝟙-𝑑𝑥² } ⇔
    ///
    ///     𝜓: 𝐸𝐸 ⟶ 𝐸𝑊, (𝑥, 𝑦) ⟼ (🐶🐱𝑥⁻², 🐶🐱𝟚𝑥³)
    ///
    ///
    /// # Mappings to Twisted Edwards form:
    ///     𝜑: 𝐸𝑊 ⟶ 𝐸𝐸, (𝑥, 𝑦) ⟼ (𝟚𝑢𝑣⁻¹, (𝑢-𝑎+𝑑)(𝑢+𝑎-𝑑)⁻¹)
    ///
    case twistedEdwards

    ///
    /// Twisted Jacobi intersection form (`𝐼`) of a curve:
    /// - Covers all elliptic curves with exactly 𝟛 points of order 𝟚
    /// - New addition for homogeneous projective coordinates
    /// - Group operation speed using extended coordinates:
    ///   - Double: 𝟚M+𝟝S
    ///   - Add: 𝟙𝟙M
    ///
    ///
    /// # Equation
    ///     𝐼: 𝑏𝑠² + 𝑐² = 𝟙, 𝑎𝑠² + 𝑑² = 𝟙
    ///
    ///
    /// # 𝐼 is birationally equivalent to:
    ///     𝑊: 𝑣² = 𝑢(𝑢-𝑎)(𝑢-𝑏)
    ///
    /// # Mappings to Weierstrass form:
    ///     𝜓: 𝐸𝐼 ⟶ 𝐸𝑊, (𝑠, 𝑐, 𝑑) ⟼ ( (𝟙+𝑐)(𝟙+𝑑)𝑠⁻², -(𝟙+𝑐)(𝟙+𝑑)(𝑐+𝑑)𝑠⁻³)
    ///
    ///     ⇔ substitution: { 🐶 = (𝟙+𝑐), 🐱 = 𝟙+𝑑, 🐭 = 𝑠⁻² } ⇔
    ///
    ///     𝜓 ⟼ (🐶🐱🐭, -🐶🐱🐭(𝑐+𝑑)𝑠⁻¹)
    ///
    ///
    /// # Mapping to Twisted Jacobi intersection form:
    ///     𝜑: 𝐸𝑊 ⟶ 𝐸𝐼, (𝑢, 𝑣) ⟼ (  𝟚𝑣(𝑎𝑏-𝑢²)⁻¹,  𝟚u(𝑏-𝑢)(𝑎𝑏-𝑢²)⁻¹ -𝟙,  𝟚u(𝑎-𝑢)(𝑎𝑏-𝑢²)⁻¹ -𝟙 )
    ///
    ///     ⇔ substitution: { 🐶 = (𝑎𝑏-𝑢²)⁻¹, 🐱 = 𝟚𝑢 } ⇔
    ///
    ///     𝜑 ⟼ (𝟚𝑣🐶, (𝑏-𝑢)🐶🐱 -𝟙, (𝑎-𝑢)🐶🐱 -𝟙)
    ///
    case twistedJacobiIntersection
}
