import Foundation
import Combine
import HttpRequest
import SharedModels

public struct UserClient {

  public typealias UserMeHandler = (String, String) -> AnyPublisher<User, HTTPError>
  public typealias UserUpdateHandler = (User, String) -> AnyPublisher<User, HTTPError>

  public let userMeHandler: UserMeHandler
  public let update: UserUpdateHandler

  public init(
    userMeHandler: @escaping UserMeHandler,
    update:  @escaping UserUpdateHandler
  ) {
    self.userMeHandler = userMeHandler
    self.update = update
  }

}
