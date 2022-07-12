import Combine
import Foundation
import HTTPRequestKit
import SharedModels
import SwiftUI
import KeychainService
import InfoPlist

public struct DeviceClient {

    public typealias DeviceCUHandler = (Device, String) -> AnyPublisher<Device, HTTPRequest.HRError>

    public let dcu: DeviceCUHandler

    public init(dcu: @escaping DeviceCUHandler) {
        self.dcu = dcu
    }

}

// Mock
extension DeviceClient {
    public static let empty = Self(
        dcu: { _, _ in
            Just(Device.empty)
                .setFailureType(to: HTTPRequest.HRError.self)
                .eraseToAnyPublisher()
        }
    )

    public static let happyPath = Self(
        dcu: { _, _ in
            Just(Device.happyPath)
                .setFailureType(to: HTTPRequest.HRError.self)
                .eraseToAnyPublisher()
        }
    )
}

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

public struct DeviceAPI {
  public static let build = Self()

  private var baseURL: URL { EnvironmentKeys.rootURL.appendingPathComponent("/devices") }

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

    public func create(device: Device, path: String) -> AnyPublisher<Device, HTTPRequest.HRError> {
      return tokenHandle(input: device, path: path, method: .post)
        .catch { (error: HTTPRequest.HRError) -> AnyPublisher<Device, HTTPRequest.HRError> in
          Fail(error: error).eraseToAnyPublisher()
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

// Live
extension DeviceClient {
    public static func live(api: DeviceAPI) -> Self {
        .init(dcu: api.create(device:path:))
    }
}
