//
//  Live.swift
//  
//
//  Created by Saroar Khandoker on 03.03.2021.
//

import Combine
import ComposableArchitecture
import SwiftUI
import HttpRequest
import SharedModels
import KeychainService
import InfoPlist
import WebSocketClient

func token() -> AnyPublisher<String, HTTPError> {
  guard let token: AuthTokenResponse = KeychainService.loadCodable(for: .token) else {
    print(#line, "not Authorized Token are missing")
    return Fail(error: HTTPError.missingTokenFromIOS )
      .eraseToAnyPublisher()
  }

  return Just(token.accessToken)
    .setFailureType(to: HTTPError.self)
    .eraseToAnyPublisher()
}

// public class WebSocketAPI {
//
//  let queue = DispatchQueue(label: "web.socket.api")
//  private var baseURL: URL { EnvironmentKeys.webSocketURL }
//
//  public func conversations() -> AnyPublisher<ConversationResponse.Item, Never> {
//    return conversationsSubject.eraseToAnyPublisher()
//  }
//
//  public func messages() -> AnyPublisher<ChatMessageResponse.Item, Never> {
//    return messagesSubject.eraseToAnyPublisher()
//  }
//
//  private var conversationsSubject = PassthroughSubject<ConversationResponse.Item, Never>()
//  private var messagesSubject = PassthroughSubject<ChatMessageResponse.Item, Never>()
//
//  public var urlSession = URLSession(configuration: .default)
//  public var socket: URLSessionWebSocketTask!
//
//  var cancellable: AnyCancellable?
//
//  public init() {}
//
//  public static let build = WebSocketAPI()
//
//  public func stop() {
//    socket.cancel(with: .goingAway, reason: nil)
//  }
//
//  public func disconnect() {
//    socket.cancel(with: .normalClosure, reason: nil)
//  }
//
//  public func handshake() {
//
//    cancellable = token()
//      .receive(on: DispatchQueue.main)
//      .sink(receiveCompletion: { completion in
//        switch completion {
//        case .finished:
//          print(#line, "finished token task")
//        case .failure(let error):
//          print(#line, "\(error) token exprire or missing")
//        }
//      }, receiveValue: { [weak self] token in
//        guard let self = self else { return }
//        var request = URLRequest(url: self.baseURL )
//        request.addValue(
//          "Bearer \(token)",
//          forHTTPHeaderField: "Authorization"
//        )
//
//        self.socket = self.urlSession.webSocketTask(with: request)
//        self.socket.receive(completionHandler: self.onReceive)
//        self.socket.resume()
//        self.onConnect()
//      })
//
//  }
//
//  public func onConnect() {
//    guard let currentUSER: User = KeychainService.loadCodable(for: .user) else {
//      return
//    }
//
//    let onconnect = ChatOutGoingEvent.connect(currentUSER).jsonString
//
//    socket.send(.string(onconnect!)) { error in
//      if let error = error {
//        print(#line, "Error sending message", error)
//      }
//    }
//  }
//
//  public func onReceive(_ incoming: Result<URLSessionWebSocketTask.Message, Error>) {
//
//    self.socket.receive { result in
//      switch result {
//
//      case .success(let message):
//        switch message {
//        case .data(let data):
//          print(#line, data)
//        case .string(let str):
//          print(#line, str)
//          guard let data = str.data(using: .utf8) else { return }
//          self.handle(data)
//        @unknown default:
//          break
//        }
//      case .failure(let error):
//        print(#line, error)
//        self.socket.cancel(with: .goingAway, reason: nil)
//        // self.handshake()
//        return
//      }
//    }
//
//    socket.receive(completionHandler: onReceive)
//
//  }
//
//  public func send(
//    localMessage: ChatMessageResponse.Item,
//    remoteMessage: String
//  ) {
//
//    self.socket.send(.string(remoteMessage)) { [weak self] error in
//      //     if let error = error {
//      //         print("Error sending message", error)
//      //     }
//      guard error == nil else {
//        print(#line, "cant send remote msg something wrong!")
//        return
//      }
//
//      self?.messagesSubject.send(localMessage)
//    }
//
//  }
//
//  public func handle(_ data: Data) -> String {
//    let chatOutGoingEvent = ChatOutGoingEvent.decode(data: data)
//
//    switch chatOutGoingEvent {
//    case .connect(_):
//      break
//    case .disconnect(_):
//      break
//    case .conversation(let message):
//      print(#line, message)
//      self.handleMessageResponse(message)
//    case .message(let message):
//      print(#line, message)
//      self.handleMessageResponse(message)
//    case .notice(let msg):
//      print(#line, msg)
//    case .error(let error):
//      print(#line, error)
//    case .none:
//      print(#line, "decode error")
//    }
//  }
//
//  public func handleMessageResponse(_ message: ChatMessageResponse.Item) {
//    self.queue.async { [weak self] in
//      self?.messagesSubject.send(message)
//    }
//  }
//
// }
//
// extension WebSocketClient {
//  public static func live(api: WebSocketAPI) -> Self {
//    .init(
//      conversations: api.conversations,
//      messages: api.messages,
//      handshake: api.handshake,
//      onReceive: api.onReceive(_:),
//      send: api.send(localMessage:remoteMessage:),
//      onConnect: api.onConnect,
//      disconnect: api.disconnect,
//      handleData: api.handle(_:),
//      handleMessageResponse: api.handleMessageResponse(_:))
//  }
// }

extension WebSocketClient {
  public static let live = WebSocketClient(
    cancel: { id, closeCode, reason in
      .fireAndForget {
        dependencies[id]?.task.cancel(with: closeCode, reason: reason)
        dependencies[id]?.subscriber.send(completion: .finished)
        dependencies[id] = nil
      }
    },
    open: { id, url, accessToken, _ in
      Effect.run { subscriber in

        guard let authToken: AuthTokenResponse = KeychainService.loadCodable(for: .token) else {
          return AnyCancellable {
            dependencies[id]?.subscriber.send(completion: .finished)
            dependencies[id] = nil
          }
        }

        let delegate = WebSocketDelegate(
          didBecomeInvalidWithError: {
            subscriber.send(.didBecomeInvalidWithError($0 as NSError?))
          },
          didClose: {
            subscriber.send(.didClose(code: $0, reason: $1))
          },
          didCompleteWithError: {
            subscriber.send(.didCompleteWithError($0 as NSError?))
          },

          didOpenWithProtocol: {
            subscriber.send(.didOpenWithProtocol($0))
          }
        )

        var request = URLRequest(url: url )
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
        let task = session.webSocketTask(with: request)

        task.resume()
        dependencies[id] = Dependencies(delegate: delegate, subscriber: subscriber, task: task)
        return AnyCancellable {
          task.cancel(with: .normalClosure, reason: nil)
          dependencies[id]?.subscriber.send(completion: .finished)
          dependencies[id] = nil
        }
      }
    },
    receive: { id in
      .future { callback in
        dependencies[id]?.task.receive { result in
          switch result.map(Message.init) {
          case let .success(.some(message)):
            callback(.success(message))
          case .success(.none):
            callback(.failure(NSError(domain: "co.pointfree", code: 1)))
          case let .failure(error):
            callback(.failure(error as NSError))
          }
        }
      }
    },
    send: { id, message in
      .future { callback in
        dependencies[id]?.task.send(message) { error in
          callback(.success(error as NSError?))
        }
      }
    },
    sendPing: { id in
      .future { callback in
        dependencies[id]?.task.sendPing { error in
          callback(.success(error as NSError?))
        }
      }
    })
}

private var dependencies: [AnyHashable: Dependencies] = [:]
private struct Dependencies {
  let delegate: URLSessionWebSocketDelegate
  let subscriber: Effect<WebSocketClient.Action, Never>.Subscriber
  let task: URLSessionWebSocketTask
}

private class WebSocketDelegate: NSObject, URLSessionWebSocketDelegate {
  let didBecomeInvalidWithError: (Error?) -> Void
  let didClose: (URLSessionWebSocketTask.CloseCode, Data?) -> Void
  let didCompleteWithError: (Error?) -> Void
  let didOpenWithProtocol: (String?) -> Void

  init(
    didBecomeInvalidWithError: @escaping (Error?) -> Void,
    didClose: @escaping (URLSessionWebSocketTask.CloseCode, Data?) -> Void,
    didCompleteWithError: @escaping (Error?) -> Void,
    didOpenWithProtocol: @escaping (String?) -> Void
  ) {
    self.didBecomeInvalidWithError = didBecomeInvalidWithError
    self.didOpenWithProtocol = didOpenWithProtocol
    self.didCompleteWithError = didCompleteWithError
    self.didClose = didClose
  }

  func urlSession(
    _ session: URLSession,
    webSocketTask: URLSessionWebSocketTask,
    didOpenWithProtocol protocol: String?
  ) {
    self.didOpenWithProtocol(`protocol`)
  }

  func urlSession(
    _ session: URLSession,
    webSocketTask: URLSessionWebSocketTask,
    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
    reason: Data?
  ) {
    self.didClose(closeCode, reason)
  }

  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    self.didCompleteWithError(error)
  }

  func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
    self.didBecomeInvalidWithError(error)
  }
}
