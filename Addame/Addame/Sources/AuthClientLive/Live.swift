//
//  AuthAPI.swift
//  
//
//  Created by Saroar Khandoker on 28.01.2021.
//

import Combine
import Foundation
import HttpRequest
import AuthClient
import SharedModels
import InfoPlist

public struct AuthAPI {
    
  public static let build = Self ()
  
  private var baseURL: URL { EnvironmentKeys.rootURL.appendingPathComponent("/auth/") }
  
  public func login(input: AuthResponse) -> AnyPublisher<AuthResponse, HTTPError> {
    
    let builder: HttpRequest = .build(
      baseURL: baseURL,
      method: .post,
      authType: .none,
      path: "login",
      contentType: .json,
      dataType: .encodable(input: input)
    )
    
    return builder.send(scheduler: RunLoop.main)
      .map { $0 }
      .catch { (error: HTTPError) -> AnyPublisher<AuthResponse, HTTPError> in
        return Fail(error: error).eraseToAnyPublisher()
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
    
  }
  
  public func verification(input: AuthResponse) -> AnyPublisher<LoginRes, HTTPError> {
    
    let builder: HttpRequest = .build(
      baseURL: baseURL,
      method: .post,
      authType: .none,
      path: "verify_sms",
      contentType: .json,
      dataType: .encodable(input: input)
    )
    
    return builder.send(scheduler: RunLoop.main)
      .map { $0 }
      .catch { (error: HTTPError) -> AnyPublisher<LoginRes, HTTPError> in
        return Fail(error: error).eraseToAnyPublisher()
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
