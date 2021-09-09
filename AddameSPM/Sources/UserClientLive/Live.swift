//
//  UserClient.swift
//
//
//  Created by Saroar Khandoker on 27.01.2021.
//

import Combine
import Foundation
import HTTPRequestKit
import InfoPlist
import KeychainService
import SharedModels
import UserClient

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

public struct UserAPI {
  public static let build = Self()
  private var baseURL: URL { EnvironmentKeys.rootURL.appendingPathComponent("/users/") }

  private func tokenHandle<Input: Encodable, Output: Decodable>(
    input: Input,
    path: String,
    method: HTTPRequest.Method
  ) -> AnyPublisher<Output, HTTPRequest.HRError> {
    return token().flatMap { token -> AnyPublisher<Output, HTTPRequest.HRError> in
      let builder: HTTPRequest = .build(
        baseURL: baseURL,
        method: method,
        authType: .bearer(token: token),
        path: path,
        contentType: .json,
        dataType: .encodable(input: input, encoder: .init())
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

  public func me(id: String, path: String) -> AnyPublisher<User, HTTPRequest.HRError> {
    return tokenHandle(input: id, path: path, method: .get)
      .catch { (error: HTTPRequest.HRError) -> AnyPublisher<User, HTTPRequest.HRError> in
        Fail(error: error).eraseToAnyPublisher()
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }

  public func update(user: User, path: String) -> AnyPublisher<User, HTTPRequest.HRError> {
    return tokenHandle(input: user, path: path, method: .post)
      .catch { (error: HTTPRequest.HRError) -> AnyPublisher<User, HTTPRequest.HRError> in
        Fail(error: error).eraseToAnyPublisher()
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
}

extension UserClient {
  public static func live(api: UserAPI) -> Self {
    .init(
      userMeHandler: api.me(id:path:),
      update: api.update(user:path:)
    )
  }
}
