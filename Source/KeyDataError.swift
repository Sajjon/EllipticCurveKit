//
//  KeyDataError.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-06-08.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public enum KeyDataError: Int, Swift.Error {
    case stringInvalidChars, stringLengthNotEven
}
