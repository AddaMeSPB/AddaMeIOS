//
//  UserClient.swift
//  
//
//  Created by Saroar Khandoker on 27.01.2021.
//

import Combine
import Foundation
import FuncNetworking
import AddaMeModels
import UserClient
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

public struct UserAPI {
  
  public static let build = Self ()
  private var baseURL: URL { EnvironmentKeys.rootURL.appendingPathComponent("/users/") }
  
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
  
  
  public func me(id: String, path: String) -> AnyPublisher<User, HTTPError> {
    
    return tokenHandle(input: id, path: path, method: .get)
      .map { $0 }
      .catch { (error: HTTPError) -> AnyPublisher<User, HTTPError> in
        return Fail(error: error).eraseToAnyPublisher()
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
    
  }
  
  public func update(user: User, path: String) -> AnyPublisher<User, HTTPError> {
    
    return tokenHandle(input: user, path: path, method: .post)
      .map { $0 }
      .catch { (error: HTTPError) -> AnyPublisher<User, HTTPError> in
        return Fail(error: error).eraseToAnyPublisher()
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
        
  }
  
}

extension UserClient {
  public static func live(api: UserAPI) -> Self {
    .init(
      me: api.me(id:path:),
      update: api.update(user:path:)
    )
  }
}
