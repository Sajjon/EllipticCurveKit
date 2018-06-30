//
//  PrivateKey.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-06-15.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct PrivateKey {}

//# WIF stands for "Wallet Import Format"
//# In Bitcoin the WIFs begins with a leading char according to this formula
//# BTC WIF MAINNET
//## uncompressed: `5`
//## compressed: `K`
//# BTC WIF TESTNET
//## uncompressed: `9`
//## compressed: `L`
//## WIF https://en.bitcoin.it/wiki/Wallet_import_format
//## compressed WIF http://sourceforge.net/mailarchive/forum.php?thread_name=CAPg%2BsBhDFCjAn1tRRQhaudtqwsh4vcVbxzm%2BAA2OuFxN71fwUA%40mail.gmail.com&forum_name=bitcoin-development

public struct PrivateKeyWIF {}
