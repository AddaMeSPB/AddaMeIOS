//
//  UIApplicationClient.swift
//
//
//  Created by Saroar Khandoker on 05.05.2021.
//

import ComposableArchitecture
import UIKit

public struct UIApplicationClient {
  public var alternateIconName: () -> String?
  public var open: (URL, [UIApplication.OpenExternalURLOptionsKey: Any]) -> Effect<Bool, Never>
  public var openSettingsURLString: () -> String
  public var setAlternateIconName: (String?) -> Effect<Never, Error>
  public var supportsAlternateIcons: () -> Bool
}
