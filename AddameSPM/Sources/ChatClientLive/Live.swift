//
//  Live.swift
//
//
//  Created by Saroar Khandoker on 05.03.2021.
//

import ChatClient
import Combine
import Foundation
import HTTPRequestKit
import InfoPlist
import KeychainService
import SharedModels

func token() -> AnyPublisher<String, HTTPRequest.HRError> {
  guard let token: AuthTokenResponse = KeychainService.loadCodable(for: .token) else {
    print(#line, "not Authorized Token are missing")
    return Fail(error: HTTPRequest.HRError.missingTokenFromIOS)
      .eraseToAnyPublisher()
  }

  return Just(token.accessToken)
    .setFailureType(to: HTTPRequest.HRError.self)
    .eraseToAnyPublisher()
}

public struct ChatAPI {
  public static let build = Self()
  private var baseURL: URL { EnvironmentKeys.rootURL.appendingPathComponent("/messages") }

  private func tokenHandle<Input: Encodable, Output: Decodable>(
    input _: Input,
    path: String,
    method: HTTPRequest.Method,
    params: [String: Any] = [:],
    queryItems: [URLQueryItem] = []
  ) -> AnyPublisher<Output, HTTPRequest.HRError> {
    return token().flatMap { token -> AnyPublisher<Output, HTTPRequest.HRError> in
      let builder: HTTPRequest = .build(
        baseURL: baseURL,
        method: method,
        authType: .bearer(token: token),
        path: path,
        contentType: .json,
        dataType: !params.isEmpty ? .query(with: params) : .query(with: queryItems)
      )

      return builder.send(scheduler: RunLoop.main)
        .catch { (error: HTTPRequest.HRError) -> AnyPublisher<Output, HTTPRequest.HRError> in
          Fail(error: error).eraseToAnyPublisher()
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    .catch { (error: HTTPRequest.HRError) -> AnyPublisher<Output, HTTPRequest.HRError> in
      Fail(error: error).eraseToAnyPublisher()
    }
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
  }

  public func messages(
    query: QueryItem, conversationID _: String, path: String
  ) -> AnyPublisher<ChatMessageResponse, HTTPRequest.HRError> {
    return tokenHandle(input: query, path: path, method: .get, params: query.parameters)
      .catch { (error: HTTPRequest.HRError) -> AnyPublisher<ChatMessageResponse, HTTPRequest.HRError> in
        Fail(error: error).eraseToAnyPublisher()
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
}

extension ChatClient {
  public static func live(api: ChatAPI) -> Self {
    .init(messages: api.messages(query:conversationID:path:))
  }
}
