## ⚠️ THIS SDK IS NOT SAFE/PRODUCTION READY (YET!) ⚠️ 
#### I'm no cryptography expert, If you find mistakes, inaccuracies or if you have suggestions for improvements of this README or the source code, please [submit an issue](https://github.com/Sajjon/EllipticCurveKit/issues/new)!

<!-- MarkdownTOC -->

- [Goal](#goal)
    - [Swifty?](#swifty)
    - [Usage](#usage)
- [Alternatives](#alternatives)
    - [Bitcoin C Bindings](#bitcoin-c-bindings)
    - [Pure Swift](#pure-swift)
- [Status](#status)
    - [Status of goal](#status-of-goal)
- [Dependencies](#dependencies)
    - [Big Numbers](#big-numbers)
        - [Apple Accelerate vBignum](#apple-accelerate-vbignum)
        - [Hash functions](#hash-functions)
- [Key inspiration](#key-inspiration)
- [Roadmap](#roadmap)
    - [Signatures](#signatures)
    - [Key Formats](#key-formats)
        - [Private Key](#private-key)
        - [Public Key](#public-key)
    - [Public Addresses](#public-addresses)
    - [Common Curves](#common-curves)

<!-- /MarkdownTOC -->


# Goal
"Swifty", safe and fast Elliptic Curve Cryptography SDK in pure Swift (no dependency to a library written in any other language than Swift).

## Swifty?
Swift is a very expressible, [type safe](https://docs.swift.org/swift-book/LanguageGuide/TheBasics.html), and [fast](https://benchmarksgame-team.pages.debian.net/benchmarksgame/faster/swift.html) programming language having the mottos ["Clarity is more important than brevity" and "Clarity at the point of use"](https://swift.org/documentation/api-design-guidelines/#fundamentals) which makes it read out as English. The main goal of this Swift SDK is to be Swifty (while also safe and fast). By the way, did you know that [Swift is the fastest growing programming language](https://www.wired.com/story/apples-swift-programming-language-is-now-top-tier/)? 

## Usage
[Swift is perfect for Protocol Oriented Programming (POP)](https://blog.bobthedeveloper.io/introduction-to-protocol-oriented-programming-in-swift-b358fe4974f) and strongly typed language, which allows for these kinds of protocols.

```swift
public protocol EllipticCurveCryptographyKeyGeneration {
    /// Elliptic Curve used, e.g. `secp256k1`
    associatedtype CurveType: EllipticCurve

    /// Generates a new key pair (PrivateKey and PublicKey)
    static func generateNewKeyPair() -> KeyPair<CurveType>

    /// Support Wallet Import Format (a.k.a. WIF)
    static func restoreKeyPairFrom(privateKey: PrivateKey<CurveType>) -> KeyPair<CurveType>

    /// A `Wallet` is a `KeyPair` and with `PublicAddresses` derived (compressed/uncompressed)
    static func createWallet(using keyPair: KeyPair<CurveType>) -> Wallet<CurveType>
}

public protocol EllipticCurveCryptographySigning {
    /// Which method to use for signing, e.g. `Schnorr`
    associatedtype SigningMethodUsed: Signing
    typealias CurveType = SigningMethodUsed.CurveType

    /// Signs `message` using `keyPair`
    static func sign(_ message: Message, using keyPair: KeyPair<CurveType>) -> SignatureType

    /// Checks if `signature` is valid for `message` or not.
    static func verify(_ message: Message, wasSignedBy signature: SignatureType, publicKey: PublicKey<CurveType>) -> Bool
}
```

Since both protocols above require an [`associatedtype`](https://docs.swift.org/swift-book/LanguageGuide/Generics.html) which specify which [Curve](#common-curves) and [Signature](#signatures) to use, we can use type-erased types, similar to Swift Foundation's [AnyCollection](https://developer.apple.com/documentation/swift/anycollection) or [AnyHashable](https://developer.apple.com/documentation/swift/anyhashable). We use type-erased wrappers `AnyKeyGenerator` and `AnyKeySigner` below: 

```swift
let privateKey = PrivateKey<Secp256k1>(hex: "B7E151628AED2A6ABF7158809CF4F3C762E7160F38B4DA56A784D9045190CFEF")!

let keyPair = AnyKeyGenerator<Secp256k1>.restoreKeyPairFrom(privateKey: privateKey)

let message = Message(hex: "243F6A8885A308D313198A2E03707344A4093822299F31D0082EFA98EC4E6C89")

let signature = AnyKeySigner<Schnorr<Secp256k1>>.sign(message, using: keyPair)

let expectedSignature = Signature<Secp256k1>(hex: "2A298DACAE57395A15D0795DDBFD1DCB564DA82B0F269BC70A74F8220429BA1D1E51A22CCEC35599B8F266912281F8365FFC2D035A230434A1A64DC59F7013FD")!

if signature == expectedSignature {
    print("Correct signature!")
}

if AnyKeySigner<Schnorr<Secp256k1>>.verify(message, wasSignedBy: signature, publicKey: keyPair.publicKey) {
     print("'It's working, it's working!' - Anakin Skywalker ( https://youtu.be/AXwGVXD7qEQ )")
}
```

The code above takes around 0.5 seconds to execute (using `Release` optimization flags), which I'm working on optimizing.

The privatekey, signature, and message hex strings above are *"Test Vector 2"* from the [Bitcoin BIP-Schnorr wiki](https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki#test-vectors).

# Alternatives
There are many - production like alternatives to this Swift SDK. The goal of this library is to be rid of dependencies to C (and other programming languages) code. While there is alternative to this Swift SDK that is written in pure swift, it is too slow (read #pure-swift).

## Bitcoin C Bindings
The [Bitcoin Core's secp256k1 library](https://github.com/bitcoin-core/secp256k1) developed in C seems to be the industry standard library for Elliptic Curve Cryptography. It is proven and robust and has many developers, why many projects in other programming languages just provide and a wrapper around it. Here is a short list of Bitcoin secp256k1 C library wrappers:

> ### Other languages
> [Go](https://github.com/toxeus/go-secp256k1), [Javascript](https://github.com/cryptocoinjs/secp256k1-node), [PHP](https://github.com/Bit-Wasp/secp256k1-php), [Python Binding](https://github.com/petertodd/python-bitcoinlib), [Ruby](https://github.com/lian/bitcoin-ruby), [Rust](https://github.com/rust-bitcoin/rust-bitcoinconsensus), [Scala](https://github.com/bitcoin-s/bitcoin-s-core)   

> ### Bitcoin C Bindings (Swift)
> There are some bindings to bitcoin-core/secp256k1 in Swift too. The most promising seems to be [kishikawakatsumi/BitcoinKit](https://github.com/kishikawakatsumi/BitcoinKit) (here are some others [Boilertalk/secp256k1.swift](https://github.com/Boilertalk/secp256k1.swift), [noxproject/ASKSecp256k1](https://github.com/noxproject/ASKSecp256k1), [pebble8888/secp256k1swift](https://github.com/pebble8888/secp256k1swift) and [skywinder/ios-secp256k1](https://github.com/skywinder/ios-secp256k1). 

> The SDK *kishikawakatsumi/BitcoinKit* stands out since it provides additional Swift layers to *bitcoin-core/secp256k1*. For production purposes, I recommend looking at [kishikawakatsumi/BitcoinKit](https://github.com/kishikawakatsumi/BitcoinKit).

## Pure Swift
The only Pure Swift Elliptic Curve cryptography SDK I have found so far is [hyugit/EllipticCurve](https://github.com/hyugit/EllipticCurve). The code is very Swifty and nice indeed, great work by [Huang Yu aka hyugit](https://github.com/hyugit)! However, the code runs too slow. Taking over 10 minutes for Key generation. While this SDK takes around 0.1 seconds (using `Release` optimization flags).

# Status

This SDK is in a proof-of-concept stage, but most features are supported, the code is Swifty and fast, but not yet safe to use. I'm working on optimizing the performance first, then making it safe to use.

## Status of goal
- [x] "Swifty"   
- [x] Fast (fastest pure Swift ECC SDK, but 250x slower than Bitcoin C SDK)
- [ ] Safe  


# Dependencies
This SDK should never require any bridge to some C library (OpenSSL or bitcoin core for example) or even Objective-C. This SDK should be "Swifty" through and through. 

## Big Numbers
Elliptic Curve Cryptography requires big numbers (256 bits and more), but natively we only have support for 64 bits (on 64-bit platforms) using [`UInt64`](https://developer.apple.com/documentation/swift/uint64). I started on developing [my own BigInt code, which I eventually throw away](https://github.com/Sajjon/EllipticCurveKit/commit/b447188a4dd303b14eb8c483bb6fde6c351c815c) since Apple Developer [Karoy Lorentey a.k.a. *"lorentey"*](https://github.com/lorentey) already created BigInt SDK [attaswift/BigInt](https://github.com/attaswift/BigInt) which works beautifully. I am also keeping an eye on a [BigInt implementation from Apple, which is in prototype stage](https://github.com/apple/swift/blob/master/test/Prototypes/BigInt.swift), might switch over to it if ever officially released.

I have also evalutated [hyugit/UInt256](https://github.com/hyugit/UInt256) which conforms to Swifts [FixedWidthInteger protocol](https://developer.apple.com/documentation/swift/fixedwidthinteger), but that won't scale well since we might need 512 and 1024 bit large numbers. I also suspect that arithemtic operations in [attaswift/BigInt](https://github.com/attaswift/BigInt) are faster than [hyugit/UInt256](https://github.com/hyugit/UInt256) (needs verification). There are also *discontinued* [CryptoCoinSwift/UInt256](https://github.com/CryptoCoinSwift/UInt256) which seems inferior to hyugit/UInt256. 

### Apple Accelerate vBignum
[Apple's library Accelerate](https://developer.apple.com/documentation/accelerate) seems to offer BigNumbers but in a very unswifty way using `UnsafePointer`s here is addition of [vbignum's vU256](https://developer.apple.com/documentation/accelerate/veclib/vbignum):
```swift
func vU256Add(_ a: UnsafePointer<vU256>, 
            _ b: UnsafePointer<vU256>, 
            _ result: UnsafeMutablePointer<vU256>)
```

However, I should probably investigate it further and measure performance. Perhaps a small struct wrapping it and decorating it with a Swifty API would give greater performance than attaswift/BigInt.

### Hash functions
I use the SHA-256 hashing functions provided by [krzyzanowskim/CryptoSwift](https://github.com/krzyzanowskim/CryptoSwift).

# Key inspiration
I have used lots of open source projects as inspiration. Bitcoin Improvement Proposal Wiki [bip-schnorr](https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki) by the bitcoin core developer [Pieter Wuille a.k.a. *"Sipa"*](https://github.com/sipa) has been a priceless inspiration for Schnorr Signature.

[Sylvestre Blanc a.k.a. *"HurlSly"*](https://github.com/HurlSly)'s [Python Code](https://github.com/HurlSly/BitcoinECCPython/blob/master/BitcoinECC.py) has also been very helpful.

# Roadmap
## Signatures
- [x] ECDSA  
- [x] Schnorr
- [ ] ed25519 (EdDSA)  

## Key Formats
### Private Key
- [x] Raw 
- [x] WIF Uncompressed
- [x] WIF Compressed

### Public Key
- [x] Uncompressed
- [x] Compressed

## Public Addresses
- [x] Bitcoin (mainnet + testnet)
- [x] Zilliqa (testnet)

## Common Curves

It is plan to support most of the common curves listed by running CLI command `openssl ecparam -list_curves`, but these four are the ones I will be starting with:

- [x] secp256k1 (Bitcoin, Ethereum, Zilliqa, Radix)
- [x] secp256r1 (NEO)
- [ ] X25519 - [Curve25519 used for ECDH](https://en.wikipedia.org/wiki/Curve25519) (Nano, Stellar, Cardano)
