import Foundation
import Combine
import FuncNetworking
import AddaMeModels

public struct UserClient {

  public typealias UserMeHandler = (String, String) -> AnyPublisher<User, HTTPError>
  public typealias UserUpdateHandler = (User, String) -> AnyPublisher<User, HTTPError>
  
  public let me: UserMeHandler
  public let update: UserUpdateHandler
  
  public init(me: @escaping UserMeHandler, update:  @escaping UserUpdateHandler) {
    self.me = me
    self.update = update
  }
  
}
