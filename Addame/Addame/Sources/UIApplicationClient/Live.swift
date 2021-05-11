//
//  Live.swift
//  
//
//  Created by Saroar Khandoker on 05.05.2021.
//

import Combine
import UIKit

extension UIApplicationClient {
  public static let live = Self(
    alternateIconName: { UIApplication.shared.alternateIconName },
    open: { url, options in
      .future { callback in
        UIApplication.shared.open(url, options: options) { bool in
          callback(.success(bool))
        }
      }
    },
    openSettingsURLString: { UIApplication.openSettingsURLString },
    setAlternateIconName: { iconName in
      .run { subscriber in
        UIApplication.shared.setAlternateIconName(iconName) { error in
          if let error = error {
            subscriber.send(completion: .failure(error))
          } else {
            subscriber.send(completion: .finished)
          }
        }
        return AnyCancellable {}
      }
    },
    supportsAlternateIcons: { UIApplication.shared.supportsAlternateIcons }
  )
}
