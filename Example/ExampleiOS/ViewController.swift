//
//  ViewController.swift
//  ExampleiOS
//
//  Created by Alexander Cyon on 2018-07-17.
//  Copyright © 2018 Sajjon. All rights reserved.
//

import UIKit

import SwiftCrypto
import CryptoSwift
import BigInt

extension UIView {
    static var spacer: UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return view
    }
}

class ViewController: UIViewController {

    private lazy var button = UIButton()
    private lazy var label = UILabel()
    private lazy var stackView = UIStackView(arrangedSubviews: [.spacer, button, label, .spacer])

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

// MARK: - Private Views
private extension ViewController {
    func setup() {
        view.backgroundColor = .white
        label.text = "NO DATA"
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .blue
        button.setTitle("Secp256r1 *", for: .normal)
        view.addSubview(stackView)
        button.addTarget(self, action: #selector(buttonPressed), for: .primaryActionTriggered)

        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }

    @objc func buttonPressed() {
        secp256r1Multiplication()
    }
}

// MARK: - Private Crypto
private extension ViewController {
    func secp256r1Multiplication() {
        print("STARTING SECP256R1 MULTIPLICATION")
        DispatchQueue.global(qos: .userInitiated).async {
            let begin = clock()
            let privateKey = PrivateKey<Secp256r1>(hex: "3D40F190DA0C18E94DB98EC34305113AAE7C51B51B6570A8FDDAA3A981CD69C3")!
            let publicKey = PublicKey<Secp256r1>(privateKey: privateKey)
            assert(publicKey.point.x == Number(hexString: "ED4AB8839C65C65A88F0F288ED9C443F9C5488323E61ED7DBB8EDF9BE6B1746D")!)
            assert(publicKey.point.y == Number(hexString: "3E13BE2FFCB19403A761420B1D26AF55E265A6F924FE0B7174D4D3654249092F")!)
            let diff = Double(clock() - begin) / Double(CLOCKS_PER_SEC)
            DispatchQueue.main.async { [weak self] in
                let message = "Time: `\(diff)` seconds"
                print("Success! \(message)")
                self?.label.text = message
            }
        }
        print("(multiplication running in background)")
    }
}
