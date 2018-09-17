//
//  HMAC_DRBG_Tests.swift
//  EllipticCurveKitTests
//
//  Created by Alexander Cyon on 2018-09-15.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import XCTest
@testable import EllipticCurveKit

struct HMACTestConfigurationRaw: Codable {
    enum CodingKeys: String, CodingKey {
        case isPredictionResistance = "PredictionResistance"
        case entropyInputBitLength = "EntropyInputLen"
        case nonceBitLength = "NonceLen"
        case personalizationStringBitLength = "PersonalizationStringLen"
        case additionalInputBitLength = "AdditionalInputLen"
        case expectedResultBitLength = "ReturnedBitsLen"

        case hashFunction, zipDownloadURL, filePathInZip
    }

    let hashFunction: String
    let zipDownloadURL: URL
    let filePathInZip: URL
    let isPredictionResistance: Bool
    let entropyInputBitLength: Int
    let nonceBitLength: Int
    let personalizationStringBitLength: Int
    let additionalInputBitLength: Int
    let expectedResultBitLength: Int

}

struct HMACTestConfiguration {
    let hasher: UpdatableHasher
    let zipDownloadURL: URL
    let filePathInZip: URL
    let isPredictionResistance: Bool
    let entropyInputByteLength: Int
    let nonceByteLength: Int
    let personalizationStringByteLength: Int
    let additionalInputByteLength: Int
    let expectedResultByteLength: Int
}

extension HMACTestConfiguration: CustomStringConvertible {
    var description: String {
        return """
        vector test suite: \(filePathInZip)
        nonce byte length: \(nonceByteLength)
        expected byte length: \(expectedResultByteLength)
        """
    }
}


extension HMACTestConfigurationRaw {
    //    var hasher: UpdatableHasher
    func asConfiguration() -> HMACTestConfiguration {
        return HMACTestConfiguration(
            hasher: { () -> UpdatableHasher in
                switch hashFunction {
                case "sha256": return UpdatableHashProvider.hasher(variant: .sha2sha256)
                default: fatalError("incorrect implementation")
                }
        }(),
            zipDownloadURL: zipDownloadURL,
            filePathInZip: filePathInZip,
            isPredictionResistance: isPredictionResistance,
            entropyInputByteLength: entropyInputBitLength / 8,
            nonceByteLength: nonceBitLength / 8,
            personalizationStringByteLength: personalizationStringBitLength / 8,
            additionalInputByteLength: additionalInputBitLength / 8,
            expectedResultByteLength: expectedResultBitLength / 8
        )
    }
}

struct TestJSON: Codable {
    let configuration: HMACTestConfigurationRaw
    let vectors: [TestVectorStrings]
}

struct Generate: Codable {
    enum CodingKeys: String, CodingKey {
        case keyValue = "KVAfterGenerate"
        case additionalInput = "AdditionalInputForGenerate"
    }
    let keyValue: KeyValue
    let additionalInput: String?
}

struct TestVectorStrings: Codable {
    enum CodingKeys: String, CodingKey {
        case name = "Count"
        case entropy = "EntropyInput"
        case nonce = "Nonce"
        case personalizationString = "PersonalizationString"
        case entropyInputReseed = "EntropyInputReseed"
        case additionalInputReseed = "AdditionalInputReseed"
        case expected = "ReturnedBits"
        case generateCalls = "GenerateCalls"
        case keyValueAfterInit = "KeyValueAfterInit"
    }

    let name: String
    let entropy: String
    let nonce: String
    let personalizationString: String?
    let entropyInputReseed: String?
    let additionalInputReseed: String?
    let expected: String
    let keyValueAfterInit: KeyValue
    let generateCalls: [Generate]
//
//    init(name: String, entropy: String, nonce: String, expected: String, pers: String? = nil, entropyReseed: String? = nil, addReseed: String? = nil, addInit: String? = nil, addGenerate: String? = nil) {
//        self.name = name
//        self.entropy = entropy
//        self.nonce = nonce
//        self.personalizationString = pers
//        self.entropyInputReseed = entropyReseed
//        self.additionalInputReseed = addReseed
//        self.additionalInputInit = addInit
//        self.additionalInputGenerate = addGenerate
//        self.expected = expected
//    }
}


struct TestVector {
    let name: String
    let entropy: Data
    let nonce: Data
    let personalizationString: Data?
    let entropyInputReseed: Data?
    let additionalInputReseed: Data?
    let keyValueAfterInit: KeyValue
    let generateCalls: [Generate]
    let expected: Data
}

func s2d(_ string: String) -> Data {
    return Number(hexString: string)!.asTrimmedData()
}

func s2d(o string: String?) -> Data? {
    guard let string = string else { return nil }
    return s2d(string)
}

extension TestVectorStrings {
    func asTestVector() -> TestVector {



        return TestVector(
            name: name,
            entropy: s2d(entropy),
            nonce: s2d(nonce),
            personalizationString: s2d(o: personalizationString),
            entropyInputReseed: s2d(o: entropyInputReseed),
            additionalInputReseed: s2d(o: entropyInputReseed),
            keyValueAfterInit: keyValueAfterInit,
            generateCalls: generateCalls,
            expected: s2d(expected)
        )
    }
}

class HMAC_DRBG_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    private func hmacTests(from file: String) -> TestJSON {
        let t = type(of: self)
        let bundle = Bundle(for: t.self)
        if let path = bundle.path(forResource: file, ofType: "json") {
            print("found path: `\(path)`")
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                return try JSONDecoder().decode(TestJSON.self, from: data)
            } catch {
                XCTFail("Failed to parse JSON, error: \(error)")
            }
        } else {
            XCTFail("no path")
        }
        fatalError("incorrect implementation")
    }

    func perform(test vector: TestVector, with configuration: HMACTestConfiguration) {
        print("Test Vector: \n`\(vector)`")

        let hmac = HMAC_DRBG(
            hasher: configuration.hasher,
            entropy: vector.entropy,
            nonce: vector.nonce,
            personalization: vector.personalizationString
        )


        let generated1 = hmac.generateNumberOf(
            length: configuration.expectedResultByteLength,
            additionalData: s2d(o: vector.generateCalls[0].additionalInput)
        )

        XCTAssertEqual(generated1.state.v, vector.generateCalls[0].keyValue.v)
        XCTAssertEqual(generated1.state.key, vector.generateCalls[0].keyValue.key)

        let generated2 = hmac.generateNumberOf(
            length: configuration.expectedResultByteLength,
            additionalData: s2d(o: vector.generateCalls.first?.additionalInput)
        )

        XCTAssertEqual(generated2.state.v, vector.generateCalls[1].keyValue.v)
        XCTAssertEqual(generated2.state.key, vector.generateCalls[1].keyValue.key)

        XCTAssertEqual(generated2.result.asHex, vector.expected.asHex)
    }

    private func performTests(file: String) {
        let tests = hmacTests(from: file)
        let configuration = tests.configuration.asConfiguration()
        print("Config: \n`\(configuration)`\n")
        tests.vectors.map { $0.asTestVector() }.forEach {
            perform(test: $0, with: configuration)
        }
    }

    func testVectorsNoReseedNoAdditionalData() {
        performTests(file: "no_additional_data")
    }

    func testVectorsNoReseedWithAdditionalData() {
        performTests(file: "additional_data")
    }

    /*
    func testVector0() {

        let vector0Strings = TestVectorStrings(
            name: "0",
            entropy: "ca851911349384bffe89de1cbdc46e6831e44d34a4fb935ee285dd14b71a7488",
            nonce: "659ba96c601dc69fc902940805ec0ca8",
            expected: "e528e9abf2dece54d47c7e75e5fe302149f817ea9fb4bee6f4199697d04d5b89d54fbb978a15b5c443c9ec21036d2460b6f73ebad0dc2aba6e624abf07745bc107694bb7547bb0995f70de25d6b29e2d3011bb19d27676c07162c8b5ccde0668961df86803482cb37ed6d5c0bb8d50cf1f50d476aa0458bdaba806f48be9dcb8"
        )

        let vector = vector0Strings.asTestVector()

        let hmac = HMAC_DRBG(
            hasher: UpdatableHashProvider.hasher(variant: .sha2sha256),
            entropy: vector.entropy,
            nonce: vector.nonce,
            personalization: vector.personalizationString,
            expected: (initV: "e75855f93b971ac468d200992e211960202d53cf08852ef86772d6490bfb53f9", initK: "302a4aba78412ab36940f4be7b940a0c728542b8b81d95b801a57b3797f9dd6e")
        )

        let length = 1024 / 8

        let generated = hmac.generateNumberOf(
            length: length,
            additionalData: nil
        )
        XCTAssertTrue(true)

//        XCTAssertEqual(generated.asHex, vector.expectedHex)
    }

    func testVector1() {

        let vector0Strings = TestVectorStrings(
            name: "1",
            entropy: "79737479ba4e7642a221fcfd1b820b134e9e3540a35bb48ffae29c20f5418ea3",
            nonce: "3593259c092bef4129bc2c6c9e19f343",
            expected: "cf5ad5984f9e43917aa9087380dac46e410ddc8a7731859c84e9d0f31bd43655b924159413e2293b17610f211e09f770f172b8fb693a35b85d3b9e5e63b1dc252ac0e115002e9bedfb4b5b6fd43f33b8e0eafb2d072e1a6fee1f159df9b51e6c8da737e60d5032dd30544ec51558c6f080bdbdab1de8a939e961e06b5f1aca37"
        )

        let vector = vector0Strings.asTestVector()

        let hmac = HMAC_DRBG(
            hasher: UpdatableHashProvider.hasher(variant: .sha2sha256),
            entropy: vector.entropy,
            nonce: vector.nonce,
            personalization: vector.personalizationString,
            expected: (initV: "b57cb403b6cd62860139c3484c9a5998fd0d82670846a765a87c9ead65f663c5", initK: "587959c1169cc9a308506ea52c2648cebf4498a35d71f6329e457ecc3204ca50")
        )

        let length = 1024 / 8

        let generated = hmac.generateNumberOf(
            length: length,
            additionalData: nil
        )
        XCTAssertTrue(true)

        //        XCTAssertEqual(generated.asHex, vector.expectedHex)
    }

    func testVectorPers0() {

        let vector0Strings = TestVectorStrings(
            name: "0",
            entropy: "5cacc68165a2e2ee20812f35ec73a79dbf30fd475476ac0c44fc6174cdac2b55",
            nonce: "6f885496c1e63af620becd9e71ecb824",
            expected: "f1012cf543f94533df27fedfbf58e5b79a3dc517a9c402bdbfc9a0c0f721f9d53faf4aafdc4b8f7a1b580fcaa52338d4bd95f58966a243cdcd3f446ed4bc546d9f607b190dd69954450d16cd0e2d6437067d8b44d19a6af7a7cfa8794e5fbd728e8fb2f2e8db5dd4ff1aa275f35886098e80ff844886060da8b1e7137846b23b",
            pers: "e72dd8590d4ed5295515c35ed6199e9d211b8f069b3058caa6670b96ef1208d0"
        )

        let vector = vector0Strings.asTestVector()

        let hmac = HMAC_DRBG(
            hasher: UpdatableHashProvider.hasher(variant: .sha2sha256),
            entropy: vector.entropy,
            nonce: vector.nonce,
            personalization: vector.personalizationString,
            expected: (initV: "b20d8765204d8bbdda55239d8dafae51ed293a627a589a8c3b315e26d85163a5", initK: "842cc7096968c8263d93d7f1eb9e9e74f78cdb5d87a6d75c72f6df1031bb4694")
        )

        let length = 1024 / 8

//        hmac.generateNumberOf(
//            length: length,
//            additionalData: nil
//        )
//
//        hmac.generateNumberOf(
//            length: length,
//            additionalData: nil
//        )
//
//        hmac.generateNumberOf(
//            length: length,
//            additionalData: nil
//        )

        let generated1 = hmac.generateNumberOf(
            length: length,
            additionalData: nil,
            assert: (_V: "66d179955bec1af89758a8fdc2a0bfe56d844b80b60381c5b0c5ec0d066edde7", _K: "1c5645bc723ed18d3ecb130bb079efb744e9759ca623e7153c01f6aea2afa08c")
        )

        let generated2 = hmac.generateNumberOf(
            length: length,
            additionalData: nil,
            assert: (_V: "84d03397e6295d67aed7358e27c5ca72849f09364483d45b51e6019df3ab00fb", _K: "823ee6a2300698649af3c2ae788947bcaee88b9bf7e06e9821d346b7fff3eb08")
        )
        XCTAssertTrue(true)

        XCTAssertEqual(generated2.asHex, vector.expectedHex)
    }


// [SHA-256]
// [PredictionResistance = False]
// [EntropyInputLen = 256]
// [NonceLen = 128]
// [PersonalizationStringLen = 256]
// [AdditionalInputLen = 256]
// [ReturnedBitsLen = 1024]
    func testVectorPersAdd0() {

        let vector0Strings = TestVectorStrings(
            name: "0",
            entropy: "5d3286bc53a258a53ba781e2c4dcd79a790e43bbe0e89fb3eed39086be34174b",
            nonce: "c5422294b7318952ace7055ab7570abf",
            expected: "d04678198ae7e1aeb435b45291458ffde0891560748b43330eaf866b5a6385e74c6fa5a5a44bdb284d436e98d244018d6acedcdfa2e9f499d8089e4db86ae89a6ab2d19cb705e2f048f97fb597f04106a1fa6a1416ad3d859118e079a0c319eb95686f4cbcce3b5101c7a0b010ef029c4ef6d06cdfac97efb9773891688c37cf",
            pers: "2dba094d008e150d51c4135bb2f03dcde9cbf3468a12908a1b025c120c985b9d"
//            addInit: "793a7ef8f6f0482beac542bb785c10f8b7b406a4de92667ab168ecc2cf7573c6",
//            addGenerate: "2238cdb4e23d629fe0c2a83dd8d5144ce1a6229ef41dabe2a99ff722e510b530"
        )

        let vector = vector0Strings.asTestVector()

        let hmac = HMAC_DRBG(
            hasher: UpdatableHashProvider.hasher(variant: .sha2sha256),
            entropy: vector.entropy,
            nonce: vector.nonce,
            personalization: vector.personalizationString,
            expected: (initV: "2ccbf4b25c4b263d59b14080c83492b05769b583adf37c57b7eb59ab07bb4d40", initK: "87ce5b45d0964e20e5e56418ae1de8b6b5fa6cdf4ff0efe5ab4444bce5658b99")
        )

        let length = 1024 / 8

        let _ = hmac.generateNumberOf(
            length: length,
            additionalData: s2d("793a7ef8f6f0482beac542bb785c10f8b7b406a4de92667ab168ecc2cf7573c6"),
            assert: (_V: "09a7df20d9f87656efa075fae3f8db432904bbd3165b125b1a688a8b5c4de88f", _K: "c60114af6165b77a36dbab54b96c21bae4a3aa329782f4b850f423eb3b760483")
        )
        let generated = hmac.generateNumberOf(
            length: length,
            additionalData: s2d("2238cdb4e23d629fe0c2a83dd8d5144ce1a6229ef41dabe2a99ff722e510b530"),
            assert: (_V: "7925c738fb6e7f7c7e147cb3b8b306b485a545ae63dc878cc49dd93e86dbed9b", _K: "ef3855c4da0eb30c90a935c98006bac71059d1a4884bc7e63f28fe56df4e92a6")
        )
//
        XCTAssertEqual(generated.asHex, vector.expectedHex)
    }*/
}
extension TestVector: CustomStringConvertible {
    var description: String {
        return """
        name: \(name)
        entropy: \(entropy.toHexString())
        nonce: \(nonce.toHexString())
        pers: \(String(describing: personalizationString?.toHexString()))
        """
    }
}
