//
//  ViewController.swift
//  ExampleiOS
//
//  Created by Alexander Cyon on 2018-07-17.
//  Copyright © 2018 Sajjon. All rights reserved.
//

import UIKit

import EllipticCurveKit
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

    private lazy var secp256r1 = makeButton("secp256r1", target: self, #selector(secp256r1Pressed))
    private lazy var secp256k1 = makeButton("secp256k1", target: self, #selector(secp256k1Pressed))
    private lazy var label = UILabel()
    private lazy var stackView = UIStackView(arrangedSubviews: [.spacer, secp256r1, secp256k1, label, .spacer])

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

private func makeButton(_ text: String, target: AnyObject, _ selector: Selector) -> UIButton {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.backgroundColor = .blue
    button.setTitle(text, for: .normal)
    button.addTarget(target, action: selector, for: .primaryActionTriggered)
    return button
}

// MARK: - Private Views
private extension ViewController {
    func setup() {
        view.backgroundColor = .white
        label.text = "NO DATA"
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)


        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
}

// MARK: - Private Crypto
private extension ViewController {
    @objc func secp256r1Pressed() {
        print("STARTING SECP256R1 MULTIPLICATION")
        DispatchQueue.global(qos: .userInitiated).async {
            let begin = clock()
            let privateKey = PrivateKey<Secp256r1>(hex: "3D40F190DA0C18E94DB98EC34305113AAE7C51B51B6570A8FDDAA3A981CD69C3")!
            let publicKey = PublicKey<Secp256r1>(privateKey: privateKey)
            assert(publicKey.point.x == Number(hexString: "ED4AB8839C65C65A88F0F288ED9C443F9C5488323E61ED7DBB8EDF9BE6B1746D")!)
            assert(publicKey.point.y == Number(hexString: "3E13BE2FFCB19403A761420B1D26AF55E265A6F924FE0B7174D4D3654249092F")!)
            let diff = Double(clock() - begin) / Double(CLOCKS_PER_SEC)
            DispatchQueue.main.async { [weak self] in
                let text = "SECP256R1: \(diff)s"
                print("Success! \(text)")
                self?.label.text = text
            }
        }
        print("(multiplication running in background)")
    }

    @objc func secp256k1Pressed() {
        print("STARTING SECP256K1 MULTIPLICATION")
        DispatchQueue.global(qos: .userInitiated).async {
            let begin = clock()
            let privateKey = PrivateKey<Secp256r1>(hex: "29EE955FEDA1A85F87ED4004958479706BA6C71FC99A67697A9A13D9D08C618E")!
            let publicKey = PublicKey<Secp256r1>(privateKey: privateKey)
            assert(publicKey.point.x == Number(hexString: "F979F942AE743F27902B62CA4E8A8FE0F8A979EE3AD7BD0817339A665C3E7F4F")!)
            assert(publicKey.point.y == Number(hexString: "B8CF959134B5C66BCC333A968B26D0ADACCFAD26F1EA8607D647E5B679C49184")!)
            let diff = Double(clock() - begin) / Double(CLOCKS_PER_SEC)
            DispatchQueue.main.async { [weak self] in
                let text = "SECP256K1: \(diff)s"
                print("Success! \(text)")
                self?.label.text = text
            }
        }
        print("(multiplication running in background)")
    }
}
