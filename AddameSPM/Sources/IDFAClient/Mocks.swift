//
//  Mocks.swift
//  
//
//  Created by Saroar Khandoker on 04.06.2022.
//

import AdSupport
import AppTrackingTransparency
import Combine

@available(iOS 14, *)
extension IDFAClient {
    public static let noop = Self(
        requestAuthorization: { .none }
    )

    public static let authorized = Self(
        requestAuthorization: {
            .future { callBack in
                callBack(.success(.authorized))
            }
        }
    )

    public static let notDetermined = Self(
        requestAuthorization: {
            .future { callBack in
                callBack(.success(.notDetermined))
            }
        }
    )

    public static let restricted = Self(
        requestAuthorization: {
            .future { callBack in
                callBack(.success(.restricted))
            }
        }
    )

    public static let denied = Self(
        requestAuthorization: {
            .future { callBack in
                callBack(.success(.denied))
            }
        }
    )
}

#if DEBUG
  import XCTestDynamicOverlay
extension IDFAClient {
    public static let failing = Self(
        requestAuthorization: { .failing("\(Self.self).requestAuthorization is not implemented") }
    )
} // i think i dont need it as i dont have any delegate func 
#endif
