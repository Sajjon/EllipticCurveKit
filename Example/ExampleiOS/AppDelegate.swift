//
//  AppDelegate.swift
//  ExampleiOS
//
//  Created by Alexander Cyon on 2018-07-17.
//  Copyright © 2018 Sajjon. All rights reserved.
//

import UIKit
import EllipticCurveKit

@UIApplicationMain
class AppDelegate: UIResponder {
    var window: UIWindow?
}

extension AppDelegate: UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = ViewController()
        window.makeKeyAndVisible()
        self.window = window
        testHmac()
        return true
    }
}

private extension AppDelegate {
    func testHmac() {
        print("TESTING HMAC 🤖")
        let hmac = HMAC_DRBG(
            hasher: UpdatableHashProvider.hasher(variant: .sha2sha256),
            entropy: Number(hexString: "ca851911349384bffe89de1cbdc46e6831e44d34a4fb935ee285dd14b71a7488")!.asTrimmedData(),
            nonce: Number(hexString: "659ba96c601dc69fc902940805ec0ca8")!.asTrimmedData()
        )

        let generated = hmac.generateNumberOfLength( 1024 / 8)
        assert(generated == Number(hexString: "e528e9abf2dece54d47c7e75e5fe302149f817ea9fb4bee6f4199697d04d5b89d54fbb978a15b5c443c9ec21036d2460b6f73ebad0dc2aba6e624abf07745bc107694bb7547bb0995f70de25d6b29e2d3011bb19d27676c07162c8b5ccde0668961df86803482cb37ed6d5c0bb8d50cf1f50d476aa0458bdaba806f48be9dcb8")!)
        print("🌈 Epic win")
    }
}
