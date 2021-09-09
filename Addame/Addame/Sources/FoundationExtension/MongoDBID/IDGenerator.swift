//
//  MongoDBIDGenerator.swift
//
//
//  Created by Saroar Khandoker on 23.02.2021.
//

import Foundation

public class ObjectIdGenerator {
  private init() {}
  public static let shared = ObjectIdGenerator()

  private var counter = Int.random(in: 0...0xFFFFFF)

  private func incrementCounter() {
    if counter >= 0xFFFFFF {
      counter = 0
    } else {
      counter += 1
    }
  }

  public func generate() -> String {
    let time = ~(~Int(NSDate().timeIntervalSince1970))
    let random = Int.random(in: 0...0xFF_FFFF_FFFF)
    let iCounter = counter
    incrementCounter()

    var byteArray = [UInt8].init(repeating: 0, count: 12)

    byteArray[0] = UInt8((time >> 24) & 0xFF)
    byteArray[1] = UInt8((time >> 16) & 0xFF)
    byteArray[2] = UInt8((time >> 8) & 0xFF)
    byteArray[3] = UInt8(time & 0xFF)
    byteArray[4] = UInt8((random >> 32) & 0xFF)
    byteArray[5] = UInt8((random >> 24) & 0xFF)
    byteArray[6] = UInt8((random >> 16) & 0xFF)
    byteArray[7] = UInt8((random >> 8) & 0xFF)
    byteArray[8] = UInt8(random & 0xFF)
    byteArray[9] = UInt8((iCounter >> 16) & 0xFF)
    byteArray[10] = UInt8((iCounter >> 8) & 0xFF)
    byteArray[11] = UInt8(iCounter & 0xFF)

    let id =
      byteArray
      .map {
        String($0, radix: 16, uppercase: false)
          .padding(toLength: 2, withPad: "0", startingAt: 0)
      }
      .joined()

    return id
  }
}
