//
//  MyEventsReducer.swift
//  
//
//  Created by Saroar Khandoker on 16.06.2022.
//

import SwiftUI
import ComposableArchitecture
import AddaSharedModels
import EventClient
import EventClientLive

public struct MyEventsEnvironment {
    public init(eventClient: EventClient, mainQueue: AnySchedulerOf<DispatchQueue>) {
        self.eventClient = eventClient
        self.mainQueue = mainQueue
    }

    public var eventClient: EventClient
    public var mainQueue: AnySchedulerOf<DispatchQueue>
}

extension MyEventsEnvironment {
  public static let live: MyEventsEnvironment = .init(
    eventClient: .live,
    mainQueue: .main
  )
}

public let myEventsReducer = Reducer<MyEventsState, MyEventsAction, MyEventsEnvironment> { state, action, _ in
//    func fetchMoreMyEvents() -> Effect<MyEventsAction, Never> {
//      guard !state.isLoadingPage, state.canLoadMorePages else { return .none }
//
//      state.isLoadingPage = true
//
//      let query = QueryItem(page: "\(state.currentPage)", per: "10")
//
//      return environment.eventClient.events(query, "my")
//        .retry(3)
//        .receive(on: environment.mainQueue)
//        .removeDuplicates()
//        .catchToEffect(MyEventsAction.myEventsResponse)
//    }

    switch action {
    case .onApper:
        return .none
        // fetchMoreMyEvents()

    case let .myEventsResponse(.success(element)):
            state.canLoadMorePages = state.myEvents.count < element.metadata.total
            state.isLoadingPage = false
            state.currentPage += 1

            state.myEvents = .init(uniqueElements: element.items)
        return .none
    case let .myEventsResponse(.failure(error)):
        // handle error
        return .none
    }
}
