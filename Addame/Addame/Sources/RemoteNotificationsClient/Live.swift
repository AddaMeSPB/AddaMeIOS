//
//  Live.swift
//  
//
//  Created by Saroar Khandoker on 05.05.2021.
//

#if canImport(UIKit)
  import UIKit
  @available(iOSApplicationExtension, unavailable)
  extension RemoteNotificationsClient {
    public static let live = Self(
      isRegistered: { UIApplication.shared.isRegisteredForRemoteNotifications },
      register: {
        .fireAndForget {
          UIApplication.shared.registerForRemoteNotifications()
        }
      },
      unregister: {
        .fireAndForget {
          UIApplication.shared.unregisterForRemoteNotifications()
        }
      }
    )
  }
#elseif canImport(AppKit)
  import AppKit
  @available(iOSApplicationExtension, unavailable)
  extension RemoteNotificationsClient {
    public static let live = Self(
      isRegistered: { NSApplication.shared.isRegisteredForRemoteNotifications },
      register: {
        .fireAndForget {
          NSApplication.shared.registerForRemoteNotifications()
        }
      },
      unregister: {
        .fireAndForget {
          NSApplication.shared.unregisterForRemoteNotifications()
        }
      }
    )
  }
#endif
