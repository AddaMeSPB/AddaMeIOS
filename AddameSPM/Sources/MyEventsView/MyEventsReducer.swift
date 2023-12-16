//
//  MyEventsReducer.swift
//  
//
//  Created by Saroar Khandoker on 16.06.2022.
//

import SwiftUI
import ComposableArchitecture
import AddaSharedModels
import APIClient
import KeychainClient

extension MyEvents.State {

    private static var myEvents: IdentifiedArrayOf<EventResponse> = [
        .walkAroundDraff, .bicyclingDraff, .exploreAreaDraff, .runningDraff
    ]

    public static let withEvents = Self(
        myEvents: myEvents
    )
}

public struct MyEvents: Reducer {

    public struct State: Equatable {
        public init(
            isLoadingPage: Bool = false,
            canLoadMorePages: Bool = true,
            currentPage: Int = 1,
            index: Int = 0,
            myEvents: IdentifiedArrayOf<EventResponse> = [],
            user: UserOutput = .withFirstName
        ) {
            self.isLoadingPage = isLoadingPage
            self.canLoadMorePages = canLoadMorePages
            self.currentPage = currentPage
            self.index = index
            self.myEvents = myEvents
            self.user = user
        }

        public var isLoadingPage = false
        public var canLoadMorePages = true
        public var currentPage = 1
        public var index = 0
        public var myEvents: IdentifiedArrayOf<EventResponse> = []
        public var user: UserOutput
    }

    public enum MyEventAction: Equatable {}

    public enum Action: Equatable {
        case onApper
        case event(id: EventResponse.ID, action: MyEventAction)
        case myEventsResponse(TaskResult<EventsResponse>)
    }

    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.keychainClient) var keychainClient
    @Dependency(\.build) var build

    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce(self.core)
    }

    func core(state: inout State, action: Action) -> Effect<Action> {

        var fetchMoreMyEvents: Effect<Action> {
          guard !state.isLoadingPage, state.canLoadMorePages else { return .none }

          state.isLoadingPage = true

          let queryItem = QueryItem(page: state.currentPage, per: 10)

            do {
                state.user = try self.keychainClient.readCodable(.user, self.build.identifier(), UserOutput.self)
            } catch {
                //fatalError("must have user")
                return .none
            }

            return .run { send in
                await send(
                    .myEventsResponse(
                        await TaskResult {
                            try await apiClient.request(
                                for: .eventEngine(.events(.findOwnerEvetns(query: queryItem))),
                                as: EventsResponse.self,
                                decoder: .iso8601
                            )
                        }
                    )
                )
            }
        }

        switch action {
        case .onApper:
                print("My Events on Apper")

            return fetchMoreMyEvents

        case let .myEventsResponse(.success(elements)):

            print("myEventsResponse \(elements)")
            if elements.items.isEmpty && state.currentPage > 1 {
                state.currentPage = 1
                state.canLoadMorePages = true
                return .none
            }

            state.canLoadMorePages = state.myEvents.count < elements.metadata.total
            state.isLoadingPage = false
            state.currentPage += 1

            state.myEvents = .init(uniqueElements: elements.items)

            return .none

        case .myEventsResponse(.failure):
            // handle error
            return .none
        }
    }

}
