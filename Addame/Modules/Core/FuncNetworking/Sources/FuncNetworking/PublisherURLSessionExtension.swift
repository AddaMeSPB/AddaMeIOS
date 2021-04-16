//
//  PublisherURLSessionExtension.swift
//  
//
//  Created by Saroar Khandoker on 01.02.2021.
//

import Combine
import Foundation

public extension Publisher where Output == (data: Data, response: URLResponse) {
  
  func assumeHTTP() -> AnyPublisher<(data: Data, response: HTTPURLResponse), HTTPError> {
    tryMap { (data: Data, response: URLResponse) in
      guard let http = response as? HTTPURLResponse else { throw HTTPError.nonHTTPResponse }
      return (data, http)
    }
    .mapError { error in
      if error is HTTPError {
        return error as! HTTPError
      } else {
        return HTTPError.networkError(error)
      }
    }
    .eraseToAnyPublisher()
  }
}

public extension Publisher where Output == (data: Data, response: HTTPURLResponse), Failure == HTTPError {
  
  func responseData() -> AnyPublisher<Data, HTTPError> {
    tryMap { (data: Data, response: HTTPURLResponse) -> Data in
      switch response.statusCode {
      case 200...299: return data
      case 401,  403:
        // wait code
        throw HTTPError.authError(response.statusCode)
      case 400...499: throw HTTPError.requestFailed(response.statusCode)
      case 500...599: throw HTTPError.serverError(response.statusCode)
      default:
        throw HTTPError.unhandledResponse(response.statusCode)
      }
    }
    .mapError { $0 as! HTTPError }
    .eraseToAnyPublisher()
  }
}

extension Publisher where Output == (data: Data, response: HTTPURLResponse), Failure == HTTPError {
  
  func retryLimit(when: @escaping () -> Bool) -> AnyPublisher<(data: Data, response: HTTPURLResponse), HTTPError> {
    map { (data, response) in
      Swift.print("No more errors...")
      return (data: data, response: response)
    }
    .eraseToAnyPublisher()
  }
  
  
}

public extension Publisher where Output == Data, Failure == HTTPError {
  
  func decoding<D: Decodable, Decoder: TopLevelDecoder>(
    _ type: D.Type,
    decoder: Decoder
  ) -> AnyPublisher<D, HTTPError> where Decoder.Input == Data {
    decode(type: D.self, decoder: decoder)
      .mapError { error in
        if error is DecodingError {
          return HTTPError.decodingError(error as! DecodingError)
        } else {
          return error as! HTTPError
        }
        
      }
      .eraseToAnyPublisher()
  }
  
}
