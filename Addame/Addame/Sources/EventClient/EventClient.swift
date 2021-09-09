import Combine
import Foundation
import HttpRequest
import SharedModels
import SwiftUI

public struct EventClient {
  public typealias EventFetchHandler = (QueryItem, String) -> AnyPublisher<EventResponse, HTTPError>
  public typealias EventCreateHandler = (Event, String) -> AnyPublisher<Event, HTTPError>
  public let events: EventFetchHandler
  public let create: EventCreateHandler

  public init(
    events: @escaping EventFetchHandler,
    create: @escaping EventCreateHandler
  ) {
    self.events = events
    self.create = create
  }
}

extension URL {
  public static var empty = Self(string: "")!
}
