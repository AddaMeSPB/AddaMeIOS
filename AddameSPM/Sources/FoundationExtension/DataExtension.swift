//
//  DataExtension.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 29.11.2020.
//

import Foundation

extension Data {
    public var toHexString: String {
        return map { String(format: "%02.2hhx", $0) }.joined()
    }
}
