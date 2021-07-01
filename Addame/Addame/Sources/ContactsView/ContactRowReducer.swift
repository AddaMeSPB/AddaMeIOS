//
//  ContactRowReducer.swift
//  
//
//  Created by Saroar Khandoker on 25.06.2021.
//

import Combine
import ComposableArchitecture
import ComposableArchitectureHelpers
import SwiftUI
import SharedModels
import HttpRequest
import ChatView

import ChatClient
import ChatClientLive

public struct ContactRowEnvironment {}

public let contactRowReducer = Reducer<ContactRowState, ContactRowAction, ContactRowEnvironment> { state, action, _ in

  switch action {

  case let .moveToChatRoom(present):
    state.isMoving = true
    return .none
  case let .chatWith(name: name, phoneNumber: phoneNumber):
    return .none
  }
}
