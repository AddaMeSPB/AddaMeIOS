//
//  Environment.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 02.11.2020.
//

import Foundation

// let settingsURL = Bundle.module.url(forResource: "settings", withExtension: "plist")

public enum EnvironmentKeys {
  // MARK: - Keys
  private enum Keys {
    // swiftlint:disable:next nesting
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
    } // this is getting all information from main ios app

    //    guard let path = Bundle.module.path(forResource: "settings", ofType: "plist"),
    //          let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
    //      fatalError("Plist file not found")
    //    }
    //  this can be use when setting.plist will have real value :)

    return dict
  }()

  // MARK: - Plist values
  public static let rootURL: URL = {

    guard let rootURLstring = EnvironmentKeys.infoDictionary["ROOT_URL"] as? String else {
      fatalError("Root URL not set in plist for this environment")
    }

    guard let url = URL(string: rootURLstring) else {
      fatalError("Root URL is invalid")
    }

    return url
  }()

  public static let webSocketURL: URL = {

    guard let webSocketString = EnvironmentKeys.infoDictionary[Keys.Plist.webSocketURL] as? String else {
      fatalError("WEB SOCKET URL Key not set in plist for this environment")
    }

    guard let url = URL(string: webSocketString) else {
      fatalError("WEB SOCKET URL is invalid")
    }

    return url
  }()

  public static let accessKeyId: String = {

    guard let accessKeyId = EnvironmentKeys.infoDictionary["ACCESS_KEY_ID"] as? String else {
      fatalError("ACCESS_KEY_ID not set in plist for this environment")
    }

    return accessKeyId
  }()

  public static let secretAccessKey: String = {

    guard let secretAccessKey = EnvironmentKeys.infoDictionary["SECRET_ACCESS_KEY"] as? String else {
      fatalError("SECRET_ACCESS_KEY not set in plist for this environment")
    }

    return secretAccessKey
  }()

}
