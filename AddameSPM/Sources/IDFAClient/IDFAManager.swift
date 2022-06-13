//
//  IDFAManager.swift
//  
//
//  Created by Saroar Khandoker on 03.06.2022.
//

import AdSupport
import AppTrackingTransparency
import Combine

struct IDFAManager {
    public typealias ATTrackingAuthorizationStatus = () -> AnyPublisher<ATTrackingManager.AuthorizationStatus, Never>
    public var iDFAAuthorizationStatus: ATTrackingAuthorizationStatus

    public init(
        iDFAAuthorizationStatus: @escaping IDFAAuthorizationStatus
    ) {
        self.iDFAAuthorizationStatus = iDFAAuthorizationStatus
    }
}

@available(iOS 14, *)
extension IDFAManager {
    public func authorization() -> AnyPublisher<ATTrackingManager.AuthorizationStatus, Never> {
        Future<ATTrackingManager.AuthorizationStatus, Never> { promise in
            self.iDFAAuthorizationStatus { status in
                promise(.success(status))
            }
        }
        .eraseToAnyPublisher()
    }
}

//@available(iOS 14, *)
//extension IDFAManager {
//
//    // MARK: fileprivate methods
//
//    func authorization(
//        _ status: ATTrackingManager.AuthorizationStatus = ATTrackingManager.trackingAuthorizationStatus
//    ) -> ATTrackingManager.AuthorizationStatus {
//
//        switch status {
//        case .notDetermined:
//            return sendOrNotSend(status)
//
//        case .restricted, .denied:
//            return sendOrNotSend(status)
//
//        case .authorized:
//            return sendAuthorizedStatus(status)
//
//        @unknown default:
//            return status
//        }
//    }
//
//}
//
//@available(iOS 14, *)
//extension ClickStreamIDFASender {
//
//    /// Живая реализация интерфейса "ClickStreamIDFASender". Эта реализация способна
//    /// - Parameter api: Живая реализация интерфейса "ClickStreamIDFASender". Эта реализация способна
//    /// - Returns: Интерфейса "ClickStreamIDFASender"
//    @objc public static func live(api: ClickStreamIDFASenderAPI) -> ClickStreamIDFASender {
//        .init(
//            authorizationStatus: api.authorization(_:)
//        )
//    }
//}
//
