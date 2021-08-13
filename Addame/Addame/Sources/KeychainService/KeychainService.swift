//
//  KeychainService.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 26.08.2020.
//

import Foundation
import Security

let kSecClassValue = NSString(format: kSecClass)
let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
let kSecValueDataValue = NSString(format: kSecValueData)
let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
let kSecAttrServiceValue = NSString(format: kSecAttrService)
let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
let kSecReturnDataValue = NSString(format: kSecReturnData)
let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)
let kSecAttrAccessibleValue = NSString(format: kSecAttrAccessible)
let kSecAttrAccessibleAfterFirstUnlockValue = NSString(format: kSecAttrAccessibleAfterFirstUnlock)

public class KeychainService: NSObject {

    public enum Keys: NSString {
        case token, deviceToken, voipToken, user, mobileNumbers, serverContacts, deviceinfo, cllocation2d
    }

    public class func save<T: Codable>(codable: T?, for key: Keys) {
        let data = codable == nil ? Data() : try? JSONEncoder().encode(codable)
        self.save(data: data ?? Data(), for: key)
    }

    public class func loadCodable<T: Codable>(for key: Keys) -> T? {
        if let data = loadData(for: key) {
          do {
            return try JSONDecoder().decode(T.self, from: data)
          } catch {
            print(#line, error)
          }
        }
        return nil
    }

    public class func save(data: Data, for key: Keys) {
        self.save(key.rawValue, data: NSData(data: data))
    }

    public class func loadData(for key: Keys) -> Data? {
        return self.loadNSData(key.rawValue) as Data?
    }

    public class func save(string: String?, for key: Keys) {
        self.save(key.rawValue, data: (string ?? "") as NSString)
    }

    public class func loadString(for key: Keys) -> String? {
        return String(self.load(key.rawValue) ?? "")
    }

    private class func save(_ service: NSString, data: NSString) {
        let encodingRawValue = String.Encoding.utf8.rawValue
        let dataFromString: NSData = data.data(using: encodingRawValue, allowLossyConversion: false)! as NSData

        let objects = [
          kSecClassGenericPasswordValue,
          service, service, dataFromString,
          kSecAttrAccessibleAfterFirstUnlockValue
        ]
        let forKeys = [
          kSecClassValue, kSecAttrServiceValue,
          kSecAttrAccountValue, kSecValueDataValue,
          kSecAttrAccessibleValue
        ]
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(
          objects: objects,
          forKeys: forKeys
        )

        SecItemDelete(keychainQuery as CFDictionary)

        SecItemAdd(keychainQuery as CFDictionary, nil)
    }

    private class func save(_ service: NSString, data: NSData) {

      let objects = [kSecClassGenericPasswordValue, service, service, data, kSecAttrAccessibleAfterFirstUnlockValue]
      let forKeys = [
        kSecClassValue, kSecAttrServiceValue,
        kSecAttrAccountValue, kSecValueDataValue,
        kSecAttrAccessibleValue
      ]

        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: objects, forKeys: forKeys)

        SecItemDelete(keychainQuery as CFDictionary)

        SecItemAdd(keychainQuery as CFDictionary, nil)
    }

    private class func load(_ service: NSString) -> NSString? {
      let kCFBooleanTrue = kCFBooleanTrue as Any
      let objects = [
        kSecClassGenericPasswordValue,
        service, service, kCFBooleanTrue,
        kSecMatchLimitOneValue, kSecAttrAccessibleAfterFirstUnlockValue
      ]
      let forKeys = [
        kSecClassValue, kSecAttrServiceValue,
        kSecAttrAccountValue, kSecReturnDataValue,
        kSecMatchLimitValue, kSecAttrAccessibleValue
      ]

        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: objects, forKeys: forKeys)

        var dataTypeRef: AnyObject?

        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        var contentsOfKeychain: NSString?

        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? NSData {
                contentsOfKeychain = NSString(data: retrievedData as Data, encoding: String.Encoding.utf8.rawValue)
            }
        }

        return contentsOfKeychain
    }

    private class func loadNSData(_ service: NSString) -> NSData? {

        let objects = [
          kSecClassGenericPasswordValue, service, service,
          kCFBooleanTrue as Any,
          kSecMatchLimitOneValue, kSecAttrAccessibleAfterFirstUnlockValue
        ]
        let forKeys = [
          kSecClassValue, kSecAttrServiceValue,
          kSecAttrAccountValue, kSecReturnDataValue,
          kSecMatchLimitValue, kSecAttrAccessibleValue
        ]

        let keychainQuery: NSMutableDictionary = NSMutableDictionary(
          objects: objects,
          forKeys: forKeys
        )

        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        var contentsOfKeychain: NSData?

        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? NSData {
                contentsOfKeychain = retrievedData
            }
        }

        return contentsOfKeychain
    }

    public class func logout() {
      let secItemClasses = [
        kSecClassGenericPassword,
        kSecClassInternetPassword,
        kSecClassCertificate,
        kSecClassKey,
        kSecClassIdentity
      ]

      for itemClass in secItemClasses {
        let spec: NSDictionary = [kSecClass: itemClass]
        SecItemDelete(spec)
      }
    }
}
