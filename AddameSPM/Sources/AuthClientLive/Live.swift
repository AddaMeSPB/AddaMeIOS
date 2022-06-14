//
//  AuthAPI.swift
//
//
//  Created by Saroar Khandoker on 28.01.2021.
//

import AuthClient
import Combine
import Foundation
import HTTPRequestKit
import InfoPlist
import SharedModels

public struct AuthAPI {
  public static let build = Self()

  private var baseURL: URL { EnvironmentKeys.rootURL.appendingPathComponent("/auth/") }

  public func login(input: AuthResponse) -> AnyPublisher<AuthResponse, HTTPRequest.HRError> {
    let builder: HTTPRequest = .build(
      baseURL: baseURL,
      method: .post,
      authType: .none,
      path: "login",
      contentType: .json,
      dataType: .encodable(input: input)
    )

    return builder.send(scheduler: RunLoop.main)
      .catch { (error: HTTPRequest.HRError) -> AnyPublisher<AuthResponse, HTTPRequest.HRError> in
        Fail(error: error).eraseToAnyPublisher()
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }

  public func verification(input: AuthResponse) -> AnyPublisher<LoginRes, HTTPRequest.HRError> {
    let builder: HTTPRequest = .build(
      baseURL: baseURL,
      method: .post,
      authType: .none,
      path: "verify_sms",
      contentType: .json,
      dataType: .encodable(input: input)
    )

    return builder.send(scheduler: RunLoop.main)
      .catch { (error: HTTPRequest.HRError) -> AnyPublisher<LoginRes, HTTPRequest.HRError> in
        Fail(error: error).eraseToAnyPublisher()
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
}

extension AuthClient {
  public static func live(api: AuthAPI) -> Self {
    .init(login: api.login(input:), verification: api.verification(input:))
  }
}
