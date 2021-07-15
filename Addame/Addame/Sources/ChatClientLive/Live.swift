//
//  Live.swift
//  
//
//  Created by Saroar Khandoker on 05.03.2021.
//

import Combine
import Foundation
import ChatClient
import HttpRequest
import SharedModels
import InfoPlist
import KeychainService

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

public struct ChatAPI {
  public static let build = Self()
  private var baseURL: URL { EnvironmentKeys.rootURL.appendingPathComponent("/messages") }

  private func tokenHandle<Input: Encodable, Output: Decodable>(
    input: Input,
    path: String,
    method: HTTPMethod,
    params: [String: Any] = [:],
    queryItems: [URLQueryItem] = []
  ) -> AnyPublisher<Output, HTTPError> {

    return token().flatMap { token -> AnyPublisher<Output, HTTPError> in
      let builder: HttpRequest = .build(
        baseURL: baseURL,
        method: method,
        authType: .bearer(token: token),
        path: path,
        contentType: .json,
        dataType: !params.isEmpty ? .query(with: params) : .query(with: queryItems)
      )

      return builder.send(scheduler: RunLoop.main)
        .catch { (error: HTTPError) -> AnyPublisher<Output, HTTPError> in
          return Fail(error: error).eraseToAnyPublisher()
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    .catch { (error: HTTPError) -> AnyPublisher<Output, HTTPError> in
      return Fail(error: error).eraseToAnyPublisher()
    }
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
  }

  public func messages(
    query: QueryItem, conversationID: String, path: String
  ) -> AnyPublisher<ChatMessageResponse, HTTPError> {
    return tokenHandle(input: query, path: path, method: .get, params: query.parameters)
      .catch { (error: HTTPError) -> AnyPublisher<ChatMessageResponse, HTTPError> in
        return Fail(error: error).eraseToAnyPublisher()
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
