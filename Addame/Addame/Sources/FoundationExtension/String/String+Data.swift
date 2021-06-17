//
//  String+Data.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 02.09.2020.
//

import Foundation

public extension String {
  var stringToData: Data? {
    return Data(
      base64Encoded: self,
      options: Data.Base64DecodingOptions.ignoreUnknownCharacters
    )
  }
}
