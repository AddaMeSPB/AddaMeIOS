import Combine
import ComposableArchitecture
import HTTPRequestKit
import InfoPlist
import KeychainService
import AddaSharedModels
import SwiftUI

public struct WebSocketClient {
  public init(
    cancel: @escaping (String, URLSessionWebSocketTask.CloseCode, Data?) -> Effect<Never, Never>,
    `open`: @escaping (AnyHashable, URL, String, [String]) -> Effect<WebSocketClient.Action, Never>,
    receive: @escaping (String) -> Effect<WebSocketClient.Message, NSError>,
    send: @escaping (String, URLSessionWebSocketTask.Message) -> Effect<NSError?, Never>,
    sendPing: @escaping (String) -> Effect<NSError?, Never>
  ) {
    self.cancel = cancel
    self.open = `open`
    self.receive = receive
    self.send = send
    self.sendPing = sendPing
  }

  public enum Action: Equatable {
    case didBecomeInvalidWithError(NSError?)
    case didClose(code: URLSessionWebSocketTask.CloseCode, reason: Data?)
    case didCompleteWithError(NSError?)
    case didOpenWithProtocol(String?)
  }

  public enum Message: Equatable {
    case data(Data)
    case string(String)

    public init?(_ message: URLSessionWebSocketTask.Message) {
      switch message {
      case let .data(data):
        self = .data(data)
      case let .string(string):
        self = .string(string)
      @unknown default:
        return nil
      }
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
      switch (lhs, rhs) {
      case let (.data(lhs), .data(rhs)):
        return lhs == rhs
      case let (.string(lhs), .string(rhs)):
        return lhs == rhs
      case (.data, _), (.string, _):
        return false
      }
    }
  }

  public var cancel: (String, URLSessionWebSocketTask.CloseCode, Data?) -> Effect<Never, Never>
  public var `open`: (AnyHashable, URL, String, [String]) -> Effect<Action, Never>
  public var receive: (String) -> Effect<Message, NSError>
  public var send: (String, URLSessionWebSocketTask.Message) -> Effect<NSError?, Never>
  public var sendPing: (String) -> Effect<NSError?, Never>
}
