//
//  IDFAClientLive.swift
//  
//
//  Created by Saroar Khandoker on 04.06.2022.
//

import IDFAClient
import AdSupport
import AppTrackingTransparency
import Combine
import ComposableArchitecture

@available(iOS 14, *)
extension IDFAClient {
    public static let live = Self(
        requestAuthorization: {
            .future { callBack in
                ATTrackingManager.requestTrackingAuthorization { status in
                    callBack(.success(status))
                }
            }
        }
    )
}
