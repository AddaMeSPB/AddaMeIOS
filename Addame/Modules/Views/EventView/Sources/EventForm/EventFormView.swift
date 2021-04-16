//
//  EventForm.swift
//  
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import ComposableArchitecture
import Combine
import SwiftUI

public struct EventFormView: View {
  
  public init(store: Store<EventFormState, EventFormAction>) {
    self.store = store
  }

  let store: Store<EventFormState, EventFormAction>
  
  public var body: some View {
    WithViewStore(store.scope(state: EventFormViewState.init(state:) )) { viewStore in
      VStack{
        Text("Hello, world! I am Event From")
          .background(Color.red)
          .padding()
      }
      .background(Color.green.ignoresSafeArea())
      .navigationTitle("Event Form")
      .navigationBarTitleDisplayMode(.inline)
      .onAppear { viewStore.send(.didAppear) }
      .onDisappear { viewStore.send(.didDisappear) }
    }
  }
}

public struct EventFormState: Equatable {}

public struct EventFormViewState: Equatable {
  public init(state: EventFormState) {}
}

public enum EventFormAction: Equatable {
  case didAppear
  case didDisappear
}

public let eventFormReducer = Reducer<EventFormState, EventFormAction, Void> { state, action, _ in
  switch action {
  case .didAppear:
    return .none
  case .didDisappear:
    return .none
  }
}

func cancelEventFormReducerEffects<T>(state: EventFormState) -> Effect<T, Never> {
  Effect<EventFormState, Never>.cancel(id: UUID()).fireAndForget()
}
