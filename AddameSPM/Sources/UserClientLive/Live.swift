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
import AddaSharedModels
import UserClient
import URLRouting

extension UserClient {
    public static var live: UserClient =
    .init(
        userMeHandler: { id in
            return try await UserClient.apiClient.decodedResponse(
                for: .authEngine(.users(.user(id: id, route: .find))),
                as: UserOutput.self,
                decoder: .ISO8601JSONDecoder
            ).value
        },
      update: { userInput in
          return try await UserClient.apiClient.decodedResponse(
            for: .authEngine(.users(.update(input: userInput))),
            as: UserOutput.self,
            decoder: .ISO8601JSONDecoder
          ).value
      },
      delete: { id in

          return try await UserClient.apiClient.data(
            for: .authEngine(.users(.user(id: id, route: .delete)))
          ).response.isResponseOK()

//          return try await UserClient.apiClient.decodedResponse(
//            for: .authEngine(.users(.user(id: id, route: .delete))),
//            as: DeleteResponse.self
//          ).value
      }
    )
}

 extension URLResponse {
     func isResponseOK() -> Bool {
         if let httpResponse = self as? HTTPURLResponse {
             return (200...299).contains(httpResponse.statusCode)
         }
         return false
     }
 }
