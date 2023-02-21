import ComposableArchitecture
import XCTestDynamicOverlay
import WebSocketClient
import Foundation
import AddaSharedModels
import Dependencies
import Foundation


public struct WebSocketReducer: ReducerProtocol {
    public struct State: Equatable {
        public init(
            alert: AlertState<WebSocketReducer.Action>? = nil,
            connectivityState: ConnectivityState = .disconnected,
            messageToSend: String = "",
            receivedMessages: [String] = [],
            user: UserOutput
          ) {
            self.alert = alert
            self.connectivityState = connectivityState
            self.messageToSend = messageToSend
            self.receivedMessages = receivedMessages
            self.user = user
        }

    public var alert: AlertState<Action>?
    public var connectivityState = ConnectivityState.disconnected
    public var messageToSend = ""
    public var receivedMessages: [String] = []
    public var user: UserOutput

    public enum ConnectivityState: String {
      case connected
      case connecting
      case disconnected
    }
  }

  public enum Action: Equatable {
    case alertDismissed
    case connectButtonTapped
    case messageToSendChanged(String)
    case receivedSocketMessage(TaskResult<WebSocketClient.Message>)
    case sendButtonTapped
    case sendResponse(didSucceed: Bool)
    case webSocket(WebSocketClient.Action)
  }

  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.webSocket) var webSocket
  private enum WebSocketID {}

  public init() {}

  public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case .alertDismissed:
      state.alert = nil
      return .none

    case .connectButtonTapped:
      switch state.connectivityState {
      case .connected, .connecting:
        state.connectivityState = .disconnected
          
          return .cancel(id: WebSocketID.self)

          // ws:/$()/10.0.1.4:8080/v1/chat
      case .disconnected:
        state.connectivityState = .connecting
        return .run { send in
          let actions = await self.webSocket
            .open(WebSocketID.self, URL(string: "ws://192.168.9.78:8080/v1/chat")!, "", [])
          await withThrowingTaskGroup(of: Void.self) { group in
            for await action in actions {
              // NB: Can't call `await send` here outside of `group.addTask` due to task local
              //     dependency mutation in `Effect.{task,run}`. Can maybe remove that explicit task
              //     local mutation (and this `addTask`?) in a world with
              //     `Effect(operation: .run { ... })`?
              group.addTask { await send(.webSocket(action)) }
              switch action {
              case .didOpen:
                group.addTask {
                  while !Task.isCancelled {
                      try await self.mainQueue.sleep(for: .seconds(10))
                    // try await self.clock.sleep(for: .seconds(10)) // ios 16
                    try? await self.webSocket.sendPing(WebSocketID.self)
                  }
                }
                group.addTask {
                  for await result in try await self.webSocket.receive(WebSocketID.self) {
                    await send(.receivedSocketMessage(result))
                  }
                }
              case .didClose:
                return
              }
            }
          }
        }
        .cancellable(id: WebSocketID.self)
      }

    case let .messageToSendChanged(message):
      state.messageToSend = message
        return .run { send in
            await send(.sendButtonTapped)
        }

    case .receivedSocketMessage:
      return .none

    case .sendButtonTapped:
      let messageToSend = state.messageToSend
      state.messageToSend = ""
      return .task {
        try await self.webSocket.send(WebSocketID.self, .string(messageToSend))
        return .sendResponse(didSucceed: true)
      } catch: { _ in
        .sendResponse(didSucceed: false)
      }
      .cancellable(id: WebSocketID.self)

    case .sendResponse(didSucceed: false):
        if #available(iOS 15, *) {
            state.alert = AlertState {
                TextState("Could not send socket message. Connect to the server first, and try again.")
            }
        } else {
            state.alert = .init(title: TextState("Could not send socket message. Connect to the server first, and try again."))
        }
      return .none

    case .sendResponse(didSucceed: true):
      return .none

    case .webSocket(.didClose):
      state.connectivityState = .disconnected
      return .cancel(id: WebSocketID.self)

    case .webSocket(.didOpen):
        state.connectivityState = .connected
        state.receivedMessages.removeAll()
        let onconnect = ChatOutGoingEvent.connect(state.user).jsonString

        return .task {
            try await self.webSocket.send(WebSocketID.self, .string(onconnect!))
          return .sendResponse(didSucceed: true)
        } catch: { _ in
          .sendResponse(didSucceed: false)
        }
        .cancellable(id: WebSocketID.self)
    }
  }
}
