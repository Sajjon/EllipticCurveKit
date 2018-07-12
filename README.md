## ⚠️ THIS SDK IS NOT SAFE, NOT PRODUCTION READY ⚠️ (but hey, I am working on it... 👨🏻‍🔬)
#### I'm no cryptography expert, I'm learning as I go. If you find mistakes, inaccuracies or if you have suggestions for improvements in the content of this README, comments in the source code or the code itself, I would appreciate if you [submit an issue](https://github.com/Sajjon/SwiftCrypto/issues/new).

## STATUS (2018-07-12): Proof of concept in progress.

# Goal
"Swifty", safe and fast Elliptic Curve Cryptography SDK in pure Swift (no dependency to a library written in any other language than Swift).

## Swifty?
Swift is a very expressible, [type safe](https://docs.swift.org/swift-book/LanguageGuide/TheBasics.html), and [fast](https://benchmarksgame-team.pages.debian.net/benchmarksgame/faster/swift.html) programming language having the mottos ["Clarity is more important than brevity" and "Clarity at the point of use"](https://swift.org/documentation/api-design-guidelines/#fundamentals) which makes it read out as English. The main goal of this Swift SDK is to be Swifty (while also safe and fast). By the way, did you know that [Swift is the fastest growing programming language](https://www.wired.com/story/apples-swift-programming-language-is-now-top-tier/)? 


```swift
// This takes around 43 seconds which of course is terribly unacceptable. My goal is 0.01 seconds.
// TEST VECTOR 2: https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki#test-vectors

let privateKey = PrivateKey(hex: "B7E151628AED2A6ABF7158809CF4F3C762E7160F38B4DA56A784D9045190CFEF")!

// `AnyKeyGenerator` is a type erasure type, just like Swift Foundation's `AnyCollection`
let keyPair = AnyKeyGenerator<Secp256k1>.restoreKeyPairFrom(privateKey: privateKey, format: .raw)

let signature = Signature(hex: "2A298DACAE57395A15D0795DDBFD1DCB564DA82B0F269BC70A74F8220429BA1D1E51A22CCEC35599B8F266912281F8365FFC2D035A230434A1A64DC59F7013FD")

let message = Message(hex: "243F6A8885A308D313198A2E03707344A4093822299F31D0082EFA98EC4E6C89")

if AnyKeySigner<Schnorr<Secp256k1>>.verify(message, wasSignedBy: signature, using: keyPair) {
    print("'It's working, it's working!' - Anakin Skywalker ( https://youtu.be/AXwGVXD7qEQ )")
}

```

[`AnyKeyGenerator`] is A type-erased wrapper over any KeyGenerator, just like [Swift Foundation's `AnyCollection`](https://developer.apple.com/documentation/swift/anycollection)

Made possible by the fact that [Swift is perfect for Protocol Oriented Programming (POP)](https://blog.bobthedeveloper.io/introduction-to-protocol-oriented-programming-in-swift-b358fe4974f) strong type safety:
```swift
protocol EllipticCurveCryptographyKeyGeneration {

    /// Elliptic Curve used, e.g. `secp256k1`
    associatedtype Curve: EllipticCurve

    /// Generates a new key pair (PrivateKey and PublicKey)
    static func generateNewKeyPair() -> KeyPair

    /// Support Wallet Import Format (a.k.a. WIF)
    static func restoreKeyPairFrom(privateKey: PrivateKey, on format: PrivateKey.Format) -> KeyPair

    /// A `Wallet` is a `KeyPair` and with `PublicAddresses` derived (compressed/uncompressed)
    static func createWallet(using keyPair: KeyPair) -> Wallet
}

protocol EllipticCurveCryptographySigning {
    /// Which method to use for signing, e.g. `Schnorr`
    associatedtype SigningMethod: Signing

    /// Signs `message` using `keyPair`
    static func sign(_ message: Message, using keyPair: KeyPair) -> Signature

    /// Checks if `signature` is valid for `message` or not.
    static func verify(_ message: Message, wasSignedBy signature: Signature, using keyPair: KeyPair) -> Bool
}
```

# Alternatives
There are many - production like alternatives to this Swift SDK. The goal of this library is to be rid of dependencies to C (and other programming languages) code. While there is alternative to this Swift SDK that is written in pure swift, it is too slow (read #pure-swift).

## Bitcoin C Bindings
The [Bitcoin Core's secp256k1 library](https://github.com/bitcoin-core/secp256k1) developed in C seems to be the industry standard library for Elliptic Curve Cryptography. It is proven and robust and has many developers, why many projects in other programming languages just provide and a wrapper around it. Here is a short list of Bitcoin secp256k1 C library wrappers:
### Other languages
[Go](https://github.com/toxeus/go-secp256k1))
[Javascript](https://github.com/cryptocoinjs/secp256k1-node)
[PHP](https://github.com/Bit-Wasp/secp256k1-php)
[Python Binding](https://github.com/petertodd/python-bitcoinlib)
[Ruby](https://github.com/lian/bitcoin-ruby)
[Rust](https://github.com/rust-bitcoin/rust-bitcoinconsensus)
[Scala](https://github.com/bitcoin-s/bitcoin-s-core)

### Swift
There are some bindings to bitcoin-core/secp256k1 in Swift too. The most promising seems to be [kishikawakatsumi/BitcoinKit](https://github.com/kishikawakatsumi/BitcoinKit) (here are some others [Boilertalk/secp256k1.swift](https://github.com/Boilertalk/secp256k1.swift), [noxproject/ASKSecp256k1](https://github.com/noxproject/ASKSecp256k1), [pebble8888/secp256k1swift](https://github.com/pebble8888/secp256k1swift) and [skywinder/ios-secp256k1](https://github.com/skywinder/ios-secp256k1)). kishikawakatsumi/BitcoinKit stands out since it provides additional Swift layers to bitcoin-core/secp256k1. For production purposes I recommend looking at [kishikawakatsumi/BitcoinKit](https://github.com/kishikawakatsumi/BitcoinKit).

## Pure Swift
The only Pure Swift Elliptic Curve cryptography SDK I have found so far is [hyugit/EllipticCurve](https://github.com/hyugit/EllipticCurve). The code is very Swifty and nice indeed, great work by [Huang Yu aka hyugit](https://github.com/hyugit)! However, the code runs too slow. Taking over 10 minutes for Key generation. While my SDK takes around 10 seconds (of course that is too slow too by a factor of at least 100.).

# Status
## Proof Of Concept code
- [x] Generate Elliptic Curve Key Pair  
- [x] Derive address (starting with Bitcoin)  
- [x] Verify signature (Schnorr signature)  
- [ ] Sign message (Schnorr sign: currently working on this)  

## Status of goal
- [ ] "Swifty"   
- [ ] Safe  
- [ ] Fast  

This is a working in progress SDK, right now only the curve [`secp256k1`](https://en.bitcoin.it/wiki/Secp256k1)([litterature](http://www.secg.org/sec2-v2.pdf)) is supported, but planning to support all the common curves:

# Dependencies
This SDK should never require any bridge to some C library (OpenSSL or bitcoin core for example) or even Objective-C. This SDK should be "Swifty" through and through. 

## Big Numbers
Elliptic Curve Cryptography requires big numbers (256 bits and more), but natively we only have support for 64 bits (on 64-bit platforms) using [`UInt64`](https://developer.apple.com/documentation/swift/uint64). I started on developing [my own BigInt code, which I eventually throw away](https://github.com/Sajjon/SwiftCrypto/commit/b447188a4dd303b14eb8c483bb6fde6c351c815c) since Apple Developer [Karoy Lorentey a.k.a. *"lorentey"*](https://github.com/lorentey) already created BigInt SDK [attaswift/BigInt](https://github.com/attaswift/BigInt) which works beautifully. I am also keeping an eye on a [BigInt implementation from Apple, which is in prototype stage](https://github.com/apple/swift/blob/master/test/Prototypes/BigInt.swift), might switch over to it if ever officially released.

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
- [ ] ECDSA  
- [x] Schnorr (right now only `schnorr_verify` is working, but soon `schnorr_sign` too).

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
These curves are listed by the CLI command `openssl ecparam -list_curves`

- [ ] secp112r1 (SECG/WTLS curve over a 112 bit prime field)  
- [ ] secp112r2 (SECG curve over a 112 bit prime field)  
- [ ] secp128r1 (SECG curve over a 128 bit prime field)  
- [ ] secp128r2 (SECG curve over a 128 bit prime field)  
- [ ] secp160k1 (SECG curve over a 160 bit prime field)  
- [ ] secp160r1 (SECG curve over a 160 bit prime field)  
- [ ] secp160r2 (SECG/WTLS curve over a 160 bit prime field)  
- [ ] secp192k1 (SECG curve over a 192 bit prime field)  
- [ ] secp224k1 (SECG curve over a 224 bit prime field)  
- [ ] secp224r1 (NIST/SECG curve over a 224 bit prime field)  
- [x] secp256k1 (SECG curve over a 256 bit prime field)  
- [ ] secp384r1 (NIST/SECG curve over a 384 bit prime field)  
- [ ] secp521r1 (NIST/SECG curve over a 521 bit prime field)  
- [ ] prime192v1 (NIST/X9.62/SECG curve over a 192 bit prime field)  
- [ ] prime192v2 (X9.62 curve over a 192 bit prime field)  
- [ ] prime192v3 (X9.62 curve over a 192 bit prime field)  
- [ ] prime239v1 (X9.62 curve over a 239 bit prime field)  
- [ ] prime239v2 (X9.62 curve over a 239 bit prime field)  
- [ ] prime239v3 (X9.62 curve over a 239 bit prime field)  
- [ ] prime256v1 (X9.62/SECG curve over a 256 bit prime field)  
- [ ] sect113r1  (SECG curve over a 113 bit binary field)  
- [ ] sect113r2  (SECG curve over a 113 bit binary field)  
- [ ] sect131r1  (SECG/WTLS curve over a 131 bit binary field)  
- [ ] sect131r2  (SECG curve over a 131 bit binary field)  
- [ ] sect163k1  (NIST/SECG/WTLS curve over a 163 bit binary field)  
- [ ] sect163r1  (SECG curve over a 163 bit binary field)  
- [ ] sect163r2  (NIST/SECG curve over a 163 bit binary field)  
- [ ] sect193r1  (SECG curve over a 193 bit binary field)  
- [ ] sect193r2  (SECG curve over a 193 bit binary field)  
- [ ] sect233k1  (NIST/SECG/WTLS curve over a 233 bit binary field)  
- [ ] sect233r1  (NIST/SECG/WTLS curve over a 233 bit binary field)  
- [ ] sect239k1  (SECG curve over a 239 bit binary field)  
- [ ] sect283k1  (NIST/SECG curve over a 283 bit binary field)  
- [ ] sect283r1  (NIST/SECG curve over a 283 bit binary field)  
- [ ] sect409k1  (NIST/SECG curve over a 409 bit binary field)  
- [ ] sect409r1  (NIST/SECG curve over a 409 bit binary field)  
- [ ] sect571k1  (NIST/SECG curve over a 571 bit binary field)  
- [ ] sect571r1  (NIST/SECG curve over a 571 bit binary field)  