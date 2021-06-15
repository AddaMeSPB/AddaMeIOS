//
//  AppUserDefaults.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 08.11.2020.
//

import Foundation

public enum AppUserDefaults {}

public extension AppUserDefaults {
  enum Key: String {
    case isAuthorized
    case currentUser
    case token
    case cllocation
    case distance
    case isUserFristNameUpdated
  }
}

public extension AppUserDefaults {

  static func save(_ value: Any?, forKey key: Key) {
    if value is [Any] {
      UserDefaults.standard.setValue(value, forKey: key.rawValue)
    } else {
      UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    UserDefaults.standard.synchronize()
  }

  static func saveCodable<T: Codable>(_ value: T?, forKey key: Key) {
    let data = try? JSONEncoder().encode(value)
    UserDefaults.standard.set(data, forKey: key.rawValue)
    UserDefaults.standard.synchronize()
  }

  static func saveCodable<T: Codable>(_ value: [T], forKey key: Key) {
    let data = try? JSONEncoder().encode(value)
    UserDefaults.standard.set(data, forKey: key.rawValue)
    UserDefaults.standard.synchronize()
  }

  static func value<T>(forKey key: Key) -> T? where T: Decodable {
    guard let encodedData = UserDefaults.standard.data(forKey: key.rawValue) else {
      return nil
    }
    return try? JSONDecoder().decode(T.self, from: encodedData)
  }

  static func value<T>(forKey key: Key) -> [T] where T: Decodable {
    guard let encodedData = UserDefaults.standard.data(forKey: key.rawValue) else {
      return []
    }
    return (try? JSONDecoder().decode(Array<T>.self, from: encodedData)) ?? []
  }

  static func removeValue(forKey key: Key) {
    UserDefaults.standard.removeObject(forKey: key.rawValue)
    UserDefaults.standard.synchronize()
  }

//  static func resetAuthData() {
//    save(false, forKey: .isAuthorized)
//    KeychainService.save(codable: CurrentUser?.none, for: .currentUser)
//    KeychainService.save(codable: AuthTokenResponse?.none, for: .token)
//    KeychainService.logout()
//    erase()
//  }
//
  static func erase() {
    let appDomain = Bundle.main.bundleIdentifier!
    UserDefaults.standard.removePersistentDomain(forName: appDomain)
    UserDefaults.standard.synchronize()
  }

}
