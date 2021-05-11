//
//  Mocks.swift
//  
//
//  Created by Saroar Khandoker on 28.01.2021.
//

import Combine
import Foundation
import HttpRequest
import SharedModels

extension AuthClient {

    public static let happyPath = Self(
      login: { _ in
        Just(
          AuthResponse(phoneNumber: "+79218888888")
        )
        .setFailureType(to: HTTPError.self)
        .eraseToAnyPublisher()
        
      },
      verification: { _ in
        Just(
          LoginRes(
            status: "online",
            user: User(id: "5fabb05d2470c17919b3c0e2", phoneNumber: "+79218888888", firstName: "AuthClientMock", createdAt: Date(), updatedAt: Date()),
            access: AuthTokenResponse.init(accessToken: "", refreshToken: "")
          )
        )
//        .map { res in
//          KeychainService.save(codable: res.user, for: .user)
//          KeychainService.save(codable: res.access, for: .token)
//          return res
//        }
        .setFailureType(to: HTTPError.self)
        .eraseToAnyPublisher()
        
      }
    )
  

}
