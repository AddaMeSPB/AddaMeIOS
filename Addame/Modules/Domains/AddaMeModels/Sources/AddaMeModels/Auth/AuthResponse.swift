//
//  AuthResponse.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 24.08.2020.
//

import Foundation

// MARK: - Login and Verification request/response
public struct AuthResponse: Codable, Equatable {
  
  public var phoneNumber: String
  public var attemptId: String?
  public var code: String?
  public var isLoggedIn: Bool? = false
  
  public init(
    phoneNumber: String,
    attemptId: String? = nil,
    code: String? = nil,
    isLoggedIn: Bool? = false
  ) {
    self.phoneNumber = phoneNumber
    self.attemptId = attemptId
    self.code = code
    self.isLoggedIn = isLoggedIn
  }
  
  public static var draff: Self {
    .init(phoneNumber: "")
  }
  
}

public struct AuthTokenResponse: Codable, Equatable {
  
  public var accessToken: String
  public var refreshToken: String

  public init(accessToken: String, refreshToken: String) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
  }
  
}

// MARK: - Login Response
public struct LoginRes: Codable, Equatable {
  
  public let status: String
  public let user: User
  public let access: AuthTokenResponse

  public init(status: String, user: User, access: AuthTokenResponse) {
    self.status = status
    self.user = user
    self.access = access
  }
  
}
