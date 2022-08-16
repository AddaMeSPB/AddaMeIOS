//
//  Live.swift
//
//
//  Created by Saroar Khandoker on 03.03.2021.
//

import Combine
import ComposableArchitecture
import HTTPRequestKit
import InfoPlist
import KeychainService
import AddaSharedModels
import SwiftUI
import WebSocketClient

extension WebSocketClient {
  public static let live = WebSocketClient(
    cancel: { id, closeCode, reason in
      .fireAndForget {
        guard let dependency = dependencies[id] else {
          assertionFailure("dependency id is missing")
          return
        }

        dependency.task.cancel(with: closeCode, reason: reason)
        dependency.subscriber.send(completion: .finished)
        dependencies[id] = nil
      }
    },
    open: { id, url, accessToken, _ in
      Effect.run { subscriber in

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

        var request = URLRequest(url: url)
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
        guard let dependency = dependencies[id] else {
          assertionFailure("dependency id is missing")
          return
        }

        dependency.task.receive { result in
          switch result.map(Message.init) {
          case let .success(.some(message)):
            callback(.success(message))
          case .success(.none):
            callback(.failure(NSError(domain: "com.adda", code: 1)))
          case let .failure(error):
            callback(.failure(error as NSError))
          }
        }
      }
    },
    send: { id, message in
      .future { callback in
        guard let dependency = dependencies[id] else {
          assertionFailure("dependency id is missing")
          return
        }
        dependency.task.send(message) { error in
          callback(.success(error as NSError?))
        }
      }
    },
    sendPing: { id in
      .future { callback in
        guard let dependency = dependencies[id] else {
          assertionFailure("dependency id is missing")
          return
        }

        dependency.task.sendPing { error in
          callback(.success(error as NSError?))
        }
      }
    }
  )
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
    _: URLSession,
    webSocketTask _: URLSessionWebSocketTask,
    didOpenWithProtocol protocol: String?
  ) {
    didOpenWithProtocol(`protocol`)
  }

  func urlSession(
    _: URLSession,
    webSocketTask _: URLSessionWebSocketTask,
    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
    reason: Data?
  ) {
    didClose(closeCode, reason)
  }

  func urlSession(_: URLSession, task _: URLSessionTask, didCompleteWithError error: Error?) {
    didCompleteWithError(error)
  }

  func urlSession(_: URLSession, didBecomeInvalidWithError error: Error?) {
    didBecomeInvalidWithError(error)
  }
}
