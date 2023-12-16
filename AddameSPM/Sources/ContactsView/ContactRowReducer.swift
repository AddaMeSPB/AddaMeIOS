//
//  ContactRowReducer.swift
//
//
//  Created by Saroar Khandoker on 25.06.2021.
//

import ChatView
import Combine
import ComposableArchitecture
import ComposableArchitectureHelpers

import AddaSharedModels
import SwiftUI

public struct ContactRowEnvironment {}

public struct ContactRow: Reducer {
    public struct State: Equatable, Identifiable {
      public init(
        id: String? = UUID().uuidString,
        isMoving: Bool = false,
        contact: ContactOutPut
      ) {
        self.id = id
        self.isMoving = isMoving
        self.contact = contact
      }

      public var id: String?
      public var isMoving: Bool = false
      public var contact: ContactOutPut
    }

    public enum Action: Equatable {
      case moveToChatRoom(Bool)
      case chatWith(name: String, phoneNumber: String)
    }


    public init() {}

    public var body: some Reducer<State, Action> {

        Reduce(self.core)
    }

    func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {

        case .moveToChatRoom: return .none
        case .chatWith: return .none
        }
    }
}
