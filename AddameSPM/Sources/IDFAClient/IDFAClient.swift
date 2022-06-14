//
//  IDFAClient.swift
//  
//
//  Created by Saroar Khandoker on 03.06.2022.
//

import AdSupport
import AppTrackingTransparency
import Combine
import ComposableArchitecture

public struct IDFAClient {
    public typealias ATTrackingAuthorizationStatus = () -> Effect<ATTrackingManager.AuthorizationStatus, Never>
    public var requestAuthorization: ATTrackingAuthorizationStatus

    public init(
        requestAuthorization: @escaping ATTrackingAuthorizationStatus
    ) {
        self.requestAuthorization = requestAuthorization
    }
}
