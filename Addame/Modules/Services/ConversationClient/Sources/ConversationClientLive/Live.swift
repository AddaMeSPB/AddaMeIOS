//
//  ConversationAPI.swift
//  
//
//  Created by Saroar Khandoker on 22.02.2021.
//

import Combine
import Foundation
import ConversationClient
import FuncNetworking
import AddaMeModels
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

public struct ConversationAPI {
  
  public static let build = Self ()
  private var baseURL: URL { EnvironmentKeys.rootURL.appendingPathComponent("/conversations") }
  
  private func tokenHandle<Input: Encodable, Output: Decodable>(
    input: Input,
    path: String,
    method: HTTPMethod
  ) -> AnyPublisher<Output, HTTPError> {

    return token().flatMap { token -> AnyPublisher<Output, HTTPError> in
      let builder: Request = .build(
        baseURL: baseURL,
        method: method,
        authType: .bearer(token: token),
        path: path,
        contentType: .json,
        dataType: .encodable(input: input, encoder: .init() )
      )
      
      return builder.send(scheduler: RunLoop.main)
        .map { $0 }
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
  
  public func create(event: Event, path: String) -> AnyPublisher<Event, HTTPError> {
    
    return tokenHandle(input: event, path: path, method: .post)
      .map { $0 }
      .catch { (error: HTTPError) -> AnyPublisher<Event, HTTPError> in
        return Fail(error: error).eraseToAnyPublisher()
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
  
  public func create(
    conversation: CreateConversation,
    path: String
  ) -> AnyPublisher<ConversationResponse.Item, HTTPError> {
    return tokenHandle(input: conversation, path: path, method: .post)
      .map { $0 }
      .catch { (error: HTTPError) -> AnyPublisher<ConversationResponse.Item, HTTPError> in
        return Fail(error: error).eraseToAnyPublisher()
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
    
  }
  
  public func addUserToConversation(
    addUser: AddUser,
    path: String
  ) -> AnyPublisher<String, HTTPError> {
    return tokenHandle(input: addUser, path: path, method: .post)
      .map { $0 }
      .catch { (error: HTTPError) -> AnyPublisher<String, HTTPError> in
        return Fail(error: error).eraseToAnyPublisher()
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
  
  public func list(query: QueryItem, path: String ) -> AnyPublisher<ConversationResponse, HTTPError> {
    return tokenHandle(input: query, path: path, method: .get)
      .map { $0 }
      .catch { (error: HTTPError) -> AnyPublisher<ConversationResponse, HTTPError> in
        return Fail(error: error).eraseToAnyPublisher()
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
  
  
  public func find(conversationsId: String, path: String ) -> AnyPublisher<ConversationResponse.Item, HTTPError> {
    return tokenHandle(input: conversationsId, path: path, method: .get)
      .map { $0 }
      .catch { (error: HTTPError) -> AnyPublisher<ConversationResponse.Item, HTTPError> in
        return Fail(error: error).eraseToAnyPublisher()
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
