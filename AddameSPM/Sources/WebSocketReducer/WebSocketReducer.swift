import ComposableArchitecture
import XCTestDynamicOverlay
import WebSocketClient
import Foundation
import AddaSharedModels
import Dependencies
import Foundation
import os

public struct WebSocketReducer: Reducer {
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

    public enum ConnectivityState: String, Equatable {
      case connected
      case connecting
      case disconnected
    }
  }

  public enum Action: Equatable {
    case alertDismissed
    case handshake
    case reconnect
    case messageToSendChanged(String)
    case receivedSocketMessage(TaskResult<WebSocketClient.Message>)
    case sendButtonTapped
    case sendResponse(didSucceed: Bool)
    case webSocket(WebSocketClient.Action)
  }

  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.webSocket) var webSocket
  @Dependency(\.appConfiguration) var appConfiguration

  private enum WebSocketID: Hashable {}

  public init() {}

    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .alertDismissed:
      state.alert = nil
      return .none

    case .handshake:
      let switchState = state.connectivityState
      switch switchState {
      case .connected, .connecting:
          logger.info("webSocket is \(switchState.rawValue)")
          state.connectivityState = .disconnected
          return .cancel(id: WebSocketClient.ID())

      case .disconnected:
          logger.info("webSocket is disconnected")
          state.connectivityState = .connecting
          state.webSocketUrl = appConfiguration.webSocketUrl
          let webSocketString = state.webSocketUrl

          return .run { send in

          guard let webSocketUrl = URL(string: webSocketString) else { return  }
          let actions = await self.webSocket
                  .open(WebSocketClient.ID(), webSocketUrl, "", [])

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
                      // try? await self.webSocket.sendPing(WebSocketID.self)
                  }
                }
                group.addTask {
                  for await result in try await self.webSocket.receive(WebSocketClient.ID()) {
                    await send(.receivedSocketMessage(result))
                  }
                }
              case .didClose:
                return
              }
            }
          }
        }
        .cancellable(id: WebSocketClient.ID())
      }

    case .reconnect:
        return .run { send in
            try await self.mainQueue.sleep(for: .seconds(10))
            // try await self.clock.sleep(for: .seconds(10)) // ios 16
            await send(.handshake)
        }

    case let .messageToSendChanged(message):
        state.messageToSend = message
        logger.info("webSocket is connected")

        return .run { send in
            await send(.sendButtonTapped)
        }

    case let .receivedSocketMessage(.failure(error)):
        logger.error("\(#file) \(#line) \(error.localizedDescription)")
        state.connectivityState = .disconnected
            return .run { send in
                await send(.reconnect)
            }

//        .merge(
//            .cancel(id: WebSocketClient.ID()),
//            EffectTask(value: .reconnect)
//        )

    case .receivedSocketMessage:
      return .none

    case .sendButtonTapped:
      let messageToSend = state.messageToSend
      state.messageToSend = ""
      return .run { send in
          try await self.webSocket.send(WebSocketClient.ID(), .string(messageToSend))
          await send(.sendResponse(didSucceed: true))
      } catch: { _, send in
          await send(.sendResponse(didSucceed: false))
      }
      .cancellable(id: WebSocketClient.ID())

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

        let dicConnect = ChatOutGoingEvent.disconnect.jsonString

        return .run { send in
            do {
                try await self.webSocket.send(WebSocketClient.ID(), .string(dicConnect!))
            } catch {
                logger.error("WebSocket close \(error)")
            }
            await send(.sendResponse(didSucceed: true))
        }

    case .webSocket(.didOpen):
        state.connectivityState = .connected
        state.receivedMessages.removeAll()

        let connect = ChatOutGoingEvent.connect.jsonString

        return .run { send in
            try await self.webSocket.send(WebSocketClient.ID(), .string(connect!))
            await send(.sendResponse(didSucceed: true))
        } catch: { _, send in
            await send(.sendResponse(didSucceed: false))
        }
        .cancellable(id: WebSocketClient.ID())
    }
  }
}

public let logger = Logger(subsystem: "com.addame.AddaMeIOS.webSocket.reducer", category: "webSocket.reducer")
