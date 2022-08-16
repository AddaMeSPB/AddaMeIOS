//
//  ContactRowReducer.swift
//
//
//  Created by Saroar Khandoker on 25.06.2021.
//

import ChatClient
import ChatClientLive
import ChatView
import Combine
import ComposableArchitecture
import ComposableArchitectureHelpers
import HTTPRequestKit
import AddaSharedModels
import SwiftUI

public struct ContactRowEnvironment {}

public let contactRowReducer = Reducer<ContactRowState, ContactRowAction, ContactRowEnvironment> {
  _, action, _ in

  switch action {

  case let .moveToChatRoom(present): return .none
  case let .chatWith(name: name, phoneNumber: phoneNumber):
      return .none
  }
}
