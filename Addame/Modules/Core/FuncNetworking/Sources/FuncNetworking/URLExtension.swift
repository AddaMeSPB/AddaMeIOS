//
//  URLExtension.swift
//  
//
//  Created by Saroar Khandoker on 01.02.2021.
//

import Foundation

extension URL {
  func generateUrlWithQuery(with quearyItems: [URLQueryItem]) -> URL {
    var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true)!
    urlComponents.queryItems = quearyItems
    guard let url = urlComponents.url else { fatalError("Wrong URL Provided") }
    return url
  }
}
