//
//  ConversationAPI.swift
//
//
//  Created by Saroar Khandoker on 22.02.2021.
//

import Combine
import ConversationClient
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

public struct ConversationAPI {
  public static let build = Self()
  private var baseURL: URL { EnvironmentKeys.rootURL.appendingPathComponent("/conversations") }

    fileprivate func handleDataType<Input: Encodable>(
      input: Input? = nil,
      params: [String: Any] = [:],
      queryItems: [URLQueryItem] = []
    ) -> HTTPRequest.DataType {
      if !params.isEmpty {
        return .query(with: params)
      } else if !queryItems.isEmpty {
        return .query(with: queryItems)
      } else {
        return .encodable(input: input, encoder: .init())
      }
    }

  private func tokenHandle<Input: Encodable, Output: Decodable>(
    input: Input? = nil,
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
        dataType: handleDataType(input: input, params: params, queryItems: queryItems)
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

  func tokenHandle<Output: Decodable>(
    path: String,
    method: HTTPRequest.Method,
    params: [String: Any] = [:],
    queryItems: [URLQueryItem] = []
  ) -> AnyPublisher<Output, HTTPRequest.HRError> {
    return tokenHandle(
      input: Never?.none, path: path, method: method, params: params, queryItems: queryItems
    )
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
  }

  public func create(event: Event, path: String) -> AnyPublisher<Event, HTTPRequest.HRError> {
    return tokenHandle(input: event, path: path, method: .post)
      .catch { (error: HTTPRequest.HRError) -> AnyPublisher<Event, HTTPRequest.HRError> in
        Fail(error: error).eraseToAnyPublisher()
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }

  public func create(
    conversation: CreateConversation,
    path: String
  ) -> AnyPublisher<ConversationResponse.Item, HTTPRequest.HRError> {
    return tokenHandle(input: conversation, path: path, method: .post)
      .catch { (error: HTTPRequest.HRError) -> AnyPublisher<ConversationResponse.Item, HTTPRequest.HRError> in
        Fail(error: error).eraseToAnyPublisher()
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }

  public func addUserToConversation(
    addUser: AddUser,
    path: String
  ) -> AnyPublisher<ConversationResponse.UserAdd, HTTPRequest.HRError> {
    return tokenHandle(
      path: path, method: .post,
      params: [
        "conversationsId": addUser.conversationsId,
        "usersId": addUser.usersId
      ]
    )
    .catch { (error: HTTPRequest.HRError) -> AnyPublisher<ConversationResponse.UserAdd, HTTPRequest.HRError> in
      Fail(error: error).eraseToAnyPublisher()
    }
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
  }

  public func list(query: QueryItem, path: String) -> AnyPublisher<ConversationResponse, HTTPRequest.HRError> {
    return tokenHandle(input: query, path: path, method: .get)
      .catch { (error: HTTPRequest.HRError) -> AnyPublisher<ConversationResponse, HTTPRequest.HRError> in
        Fail(error: error).eraseToAnyPublisher()
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }

  public func find(conversationsId: String, path: String) -> AnyPublisher<
    ConversationResponse.Item, HTTPRequest.HRError
  > {
    return tokenHandle(
      path: path, method: .get,
      params: ["conversationsId": conversationsId]
    )
    .catch { (error: HTTPRequest.HRError) -> AnyPublisher<ConversationResponse.Item, HTTPRequest.HRError> in
      Fail(error: error).eraseToAnyPublisher()
    }
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
  }
}

extension ConversationClient {
  public static func live(api: ConversationAPI) -> Self {
    .init(
      create: api.create(conversation:path:),
      addUserToConversation: api.addUserToConversation(addUser:path:),
      list: api.list(query:path:),
      find: api.find(conversationsId:path:)
    )
  }
}

extension Never: Encodable {
  public func encode(to _: Encoder) throws {
    fatalError("Never error called")
  }
}
