//
//  URLRequestInternalExtension.swift
//  
//
//  Created by Saroar Khandoker on 01.02.2021.
//

import Foundation

internal extension URLRequest {
  private var headerField: String { "Authorization" }
  private var contentTypeHeader: String { "Content-Type" }
  
  mutating func setupRequest(
    headers: [String: String]?,
    authType: AuthType,
    contentType: ContentType,
    method: HTTPMethod
  ) {
    let contentTypeHeaderName = contentTypeHeader
    allHTTPHeaderFields = headers
    setValue(contentType.content, forHTTPHeaderField: contentTypeHeaderName)
    setupAuthorization(with: authType)
    httpMethod = method.rawValue
  }
  
  mutating func setupAuthorization(with authType: AuthType) {
    switch authType {
    case .basic(let username, let password):
      let loginString = String(format: "%@:%@", username, password)
      guard let data = loginString.data(using: .utf8) else { return }
      setValue("Basic \(data.base64EncodedString())", forHTTPHeaderField: headerField)
    case .bearer(let token):
      setValue("Bearer \(token)", forHTTPHeaderField: headerField)
    case .none: break
    }
  }
}
