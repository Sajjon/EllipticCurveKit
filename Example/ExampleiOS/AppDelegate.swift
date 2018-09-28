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
        return true
    }
}
