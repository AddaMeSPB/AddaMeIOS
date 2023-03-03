import ComposableArchitecture
import XCTestDynamicOverlay
import WebSocketClient
import Foundation
import AddaSharedModels
import Dependencies
import Foundation
import os

public struct WebSocketReducer: ReducerProtocol {
    public struct State: Equatable {
        public init(
            alert: AlertState<WebSocketReducer.Action>? = nil,
            connectivityState: ConnectivityState = .disconnected,
            messageToSend: String = "",
            receivedMessages: [String] = [],
            user: UserOutput,
            webSocketUrl: String = ""
          ) {
            self.alert = alert
            self.connectivityState = connectivityState
            self.messageToSend = messageToSend
            self.receivedMessages = receivedMessages
            self.user = user
            self.webSocketUrl = webSocketUrl
        }

    public var alert: AlertState<Action>?
    public var connectivityState = ConnectivityState.disconnected
    public var messageToSend = ""
    public var receivedMessages: [String] = []
    public var user: UserOutput
    public var webSocketUrl: String = "" //= "ws://10.10.18.148:8080/v1/chat"

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
  @Dependency(\.appConfiguration) var appConfiguration

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
          logger.info("webSocket is connected")
          return .cancel(id: WebSocketID.self)

      case .disconnected:
          logger.info("webSocket is disconnected")
          state.connectivityState = .connecting
          state.webSocketUrl = appConfiguration.webSocketUrl
          let webSocketUrl = state.webSocketUrl

          return .run { send in
          let actions = await self.webSocket
                .open(WebSocketID.self, URL(string: webSocketUrl)!, "", [])
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
        logger.info("webSocket is connected")

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
        let status = state.connectivityState.rawValue
        logger.info("webSocket is connected \(status) ")
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

public let logger = Logger(subsystem: "com.addame.AddaMeIOS", category: "webSocket.reducer")
