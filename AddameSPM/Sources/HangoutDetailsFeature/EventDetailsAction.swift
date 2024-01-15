//
//  HangoutDetailsAction.swift
//
//
//  Created by Saroar Khandoker on 12.07.2021.
//

import ComposableArchitecture
import KeychainClient
import MapView
import AddaSharedModels

extension HangoutDetails.Action {
//    extension HangoutForm.Action {
//        // swiftlint:disable cyclomatic_complexity
//        init(action: EventFormView.ViewAction) {
//            switch action {
//            }
//        }
//    }
  static func view(_ localAction: HangoutDetailsView.ViewAction) -> Self {
    switch localAction {
    case .onAppear:
      return .onAppear
    case .alertDismissed:
      return .alertDismissed
    case let .moveToChatRoom(bool):
      return .moveToChatRoom(bool)
    case let .updateRegion(coordinateRegion):
      return .updateRegion(coordinateRegion)
    case .startChat(let bool):
        return .startChat(bool)
    case .askJoinRequest(let boolean):
        return .askJoinRequest(boolean)
    case .joinToEvent(let taskResult):
        return .joinToEvent(taskResult)
    case .conversationResponse(let taskResult):
        return .conversationResponse(taskResult)
    case .userResponse(let userOutput):
        return .userResponse(userOutput)
    }
  }
}
