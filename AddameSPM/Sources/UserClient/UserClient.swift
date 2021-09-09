import Combine
import Foundation
import HTTPRequestKit
import SharedModels

public struct UserClient {
  public typealias UserMeHandler = (String, String) -> AnyPublisher<User, HTTPRequest.HRError>
  public typealias UserUpdateHandler = (User, String) -> AnyPublisher<User, HTTPRequest.HRError>

  public let userMeHandler: UserMeHandler
  public let update: UserUpdateHandler

  public init(
    userMeHandler: @escaping UserMeHandler,
    update: @escaping UserUpdateHandler
  ) {
    self.userMeHandler = userMeHandler
    self.update = update
  }
}
