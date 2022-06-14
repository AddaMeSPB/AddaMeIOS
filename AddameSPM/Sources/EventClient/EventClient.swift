import Combine
import Foundation
import HTTPRequestKit
import SharedModels
import SwiftUI

public struct EventClient {
  public typealias EventFetchHandler = (QueryItem, String) -> AnyPublisher<EventResponse, HTTPRequest.HRError>
  public typealias EventCreateHandler = (Event, String) -> AnyPublisher<EventResponse.Item, HTTPRequest.HRError>
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
