//
//  Environment.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 02.11.2020.
//

import Foundation

public enum EnvironmentKeys {
  // MARK: - Keys
  private enum Keys {
     enum Plist {
      static let rootURL = "ROOT_URL"
      static let webSocketURL = "WEB_SOCKET_URL"
      static let accessKeyId = "ACCESS_KEY_ID"
      static let secretAccessKey = "SECRET_ACCESS_KEY"
    }
  }
  
  // MARK: - Plist
  private static let infoDictionary: [String: Any] = {
    
    guard let dict = Bundle.main.infoDictionary else {
      fatalError("Plist file not found")
    }
    
    return dict
  }()
  
  // MARK: - Plist values
  static let rootURL: URL = {
    
    guard let rootURLstring = EnvironmentKeys.infoDictionary["ROOT_URL"] as? String else {
      fatalError("Root URL not set in plist for this environment")
    }
    
    guard let url = URL(string: rootURLstring) else {
      fatalError("Root URL is invalid")
    }
    
    return url
  }()
  
  static let webSocketURL: URL = {
    
    guard let webSocketString = EnvironmentKeys.infoDictionary[Keys.Plist.webSocketURL] as? String else {
      fatalError("WEB SOCKET URL Key not set in plist for this environment")
    }
    
    guard let url = URL(string: webSocketString) else {
      fatalError("WEB SOCKET URL is invalid")
    }
    
    return url
  }()
  
  static let accessKeyId: String = {
    
    guard let accessKeyId = EnvironmentKeys.infoDictionary["ACCESS_KEY_ID"] as? String else {
      fatalError("ACCESS_KEY_ID not set in plist for this environment")
    }
    
    return accessKeyId
  }()
  
  static let secretAccessKey: String = {
    
    guard let secretAccessKey = EnvironmentKeys.infoDictionary["SECRET_ACCESS_KEY"] as? String else {
      fatalError("SECRET_ACCESS_KEY not set in plist for this environment")
    }
    
    return secretAccessKey
  }()
  
  
}
