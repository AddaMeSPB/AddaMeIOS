//
//  EventClientLive.swift
//  
//
//  Created by Saroar Khandoker on 25.01.2021.
//

import Combine
import Foundation
import EventClient
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

public struct EventAPI {

  public static let build = Self()

  private var baseURL: URL { EnvironmentKeys.rootURL.appendingPathComponent("/events") }

  private func tokenHandle<Input: Encodable, Output: Decodable>(
    input: Input, path: String, method: HTTPMethod
  ) -> AnyPublisher<Output, HTTPError> {

    return token().flatMap { token -> AnyPublisher<Output, HTTPError> in
      let builder: HttpRequest = .build(
        baseURL: baseURL,
        method: method,
        authType: .bearer(token: token),
        path: path,
        contentType: .json,
        dataType: .encodable(input: input, encoder: .init() )
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

  public func create(event: Event, path: String) -> AnyPublisher<Event, HTTPError> {

    return tokenHandle(input: event, path: path, method: .post)
      .catch { (error: HTTPError) -> AnyPublisher<Event, HTTPError> in
        return Fail(error: error).eraseToAnyPublisher()
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()

  }

  public func fetch(events query: QueryItem, path: String) -> AnyPublisher<EventResponse, HTTPError> {

    return tokenHandle(input: query, path: path, method: .get)
      .catch { (error: HTTPError) -> AnyPublisher<EventResponse, HTTPError> in
        return Fail(error: error).eraseToAnyPublisher()
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()

  }

  public func fetch(query: QueryItem, path: String) -> AnyPublisher<EventResponse, HTTPError> {

    return tokenHandle(input: query, path: path, method: .get)
      .catch { (error: HTTPError) -> AnyPublisher<EventResponse, HTTPError> in
        return Fail(error: error).eraseToAnyPublisher()
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
