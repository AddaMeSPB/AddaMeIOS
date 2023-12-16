import Combine
import ComposableArchitecture
import AddaSharedModels
import SwiftUI
import Dependencies
import XCTestDynamicOverlay
import APIClient

public struct WebSocketClient {
    public struct ID: Hashable, @unchecked Sendable {
      let rawValue: AnyHashable

      init<RawValue: Hashable & Sendable>(_ rawValue: RawValue) {
        self.rawValue = rawValue
      }

      public init() {
        struct RawValue: Hashable, Sendable {}
        self.rawValue = RawValue()
      }
    }

  public enum Action: Equatable {
    case didOpen(protocol: String?)
    case didClose(code: URLSessionWebSocketTask.CloseCode, reason: Data?)
  }

  public enum Message: Equatable {
    struct Unknown: Error {}

    case data(Data)
    case string(String)

    public init(_ message: URLSessionWebSocketTask.Message) throws {
      switch message {
      case let .data(data): self = .data(data)
      case let .string(string): self = .string(string)
      @unknown default: throw Unknown()
      }
    }
  }

    // ID, URL, String(AccessToken), [String]
    public var open: @Sendable (ID, URL, String, [String]) async -> AsyncStream<Action>
    public var receive: @Sendable (ID) async throws -> AsyncStream<TaskResult<Message>>
    public var send: @Sendable (ID, URLSessionWebSocketTask.Message) async throws -> Void
    public var sendPing: @Sendable (ID) async throws -> Void
}

extension WebSocketClient: DependencyKey {
    public static var liveValue: Self {
        return Self(
          open: { await WebSocketActor.shared.open(id: $0, url: $1, accessToken: $2, protocols: $3) },
          receive: { try await WebSocketActor.shared.receive(id: $0) },
          send: { try await WebSocketActor.shared.send(id: $0, message: $1) },
          sendPing: { try await WebSocketActor.shared.sendPing(id: $0) }
        )

        final actor WebSocketActor: GlobalActor {
          final class Delegate: NSObject, URLSessionWebSocketDelegate {
            var continuation: AsyncStream<Action>.Continuation?

            func urlSession(
              _: URLSession,
              webSocketTask _: URLSessionWebSocketTask,
              didOpenWithProtocol protocol: String?
            ) {
              self.continuation?.yield(.didOpen(protocol: `protocol`))
            }

            func urlSession(
              _: URLSession,
              webSocketTask _: URLSessionWebSocketTask,
              didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
              reason: Data?
            ) {
              self.continuation?.yield(.didClose(code: closeCode, reason: reason))
              self.continuation?.finish()
            }
          }

      typealias Dependencies = (socket: URLSessionWebSocketTask, delegate: Delegate)

      static let shared = WebSocketActor()


      var dependencies: [ID: Dependencies] = [:]

      func open(id: ID, url: URL, accessToken: String, protocols: [String]) -> AsyncStream<Action> {
        let delegate = Delegate()

          var request = URLRequest(url: url)
          let token = request.getToken() ?? ""
          request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")


          let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
//          let task = session.webSocketTask(with: request)

//        let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)

          let socket = session.webSocketTask(with: request)//!, protocols: protocols)

        defer { socket.resume() }
        var continuation: AsyncStream<Action>.Continuation!
        let stream = AsyncStream<Action> {
          $0.onTermination = { _ in
            socket.cancel()
            Task { await self.removeDependencies(id: id) }
          }
          continuation = $0
        }
        delegate.continuation = continuation
        self.dependencies[id] = (socket, delegate)
        return stream
      }

      func close(
        id: ID, with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?
      ) async throws {
        defer { self.dependencies[id] = nil }
        try self.socket(id: id).cancel(with: closeCode, reason: reason)
      }

      func receive(id: ID) throws -> AsyncStream<TaskResult<Message>> {
        let socket = try self.socket(id: id)
        return AsyncStream { continuation in
          let task = Task {
            while !Task.isCancelled {
              continuation.yield(await TaskResult { try await Message(socket.receive()) })
            }
            continuation.finish()
          }
          continuation.onTermination = { _ in task.cancel() }
        }
      }

      func send(id: ID, message: URLSessionWebSocketTask.Message) async throws {
        try await self.socket(id: id).send(message)
      }

      func sendPing(id: ID) async throws {
        let socket = try self.socket(id: id)
        return try await withCheckedThrowingContinuation { continuation in
          socket.sendPing { error in
            if let error = error {
              continuation.resume(throwing: error)
            } else {
              continuation.resume()
            }
          }
        }
      }

      private func socket(id: ID) throws -> URLSessionWebSocketTask {
        guard let dependencies = self.dependencies[id]?.socket else {
          struct Closed: Error {}
          throw Closed()
        }
        return dependencies
      }

      private func removeDependencies(id: ID) {
        self.dependencies[id] = nil
      }
    }
  }

  public static let testValue = Self(
    open: unimplemented("\(Self.self).open", placeholder: AsyncStream.never),
    receive: unimplemented("\(Self.self).receive"),
    send: unimplemented("\(Self.self).send"),
    sendPing: unimplemented("\(Self.self).sendPing")
  )
}

extension DependencyValues {
  public var webSocket: WebSocketClient {
    get { self[WebSocketClient.self] }
    set { self[WebSocketClient.self] = newValue }
  }
}
