//
//  EventClientLive.swift
//
//
//  Created by Saroar Khandoker on 25.01.2021.
//

import Combine
import EventClient
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

public struct EventAPI {
  public static let build = Self()

  private var baseURL: URL { EnvironmentKeys.rootURL.appendingPathComponent("/events") }

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

  public func create(event: Event, path: String) -> AnyPublisher<EventResponse.Item, HTTPRequest.HRError> {
    return tokenHandle(input: event, path: path, method: .post)
      .catch { (error: HTTPRequest.HRError) -> AnyPublisher<EventResponse.Item, HTTPRequest.HRError> in
        Fail(error: error).eraseToAnyPublisher()
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }

  public func fetch(events query: QueryItem, path: String) -> AnyPublisher<EventResponse, HTTPRequest.HRError> {
    return tokenHandle(input: query, path: path, method: .get)
      .catch { (error: HTTPRequest.HRError) -> AnyPublisher<EventResponse, HTTPRequest.HRError> in
        Fail(error: error).eraseToAnyPublisher()
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }

  public func fetch(query: QueryItem, path: String) -> AnyPublisher<EventResponse, HTTPRequest.HRError> {
    return tokenHandle(input: query, path: path, method: .get, params: query.parameters)
      .catch { (error: HTTPRequest.HRError) -> AnyPublisher<EventResponse, HTTPRequest.HRError> in
        Fail(error: error).eraseToAnyPublisher()
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
}

extension EventClient {
  public static func live(api: EventAPI) -> Self {
    .init(
      events: api.fetch(query:path:),
      create: api.create(event:path:)
    )
  }
}
