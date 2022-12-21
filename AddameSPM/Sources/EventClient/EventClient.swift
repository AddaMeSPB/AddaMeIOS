import Combine
import Foundation
import AddaSharedModels
import SwiftUI
import URLRouting
import InfoPlist

public struct EventClient {

    public static let apiClient: URLRoutingClient<SiteRoute> = .live(
      router: siteRouter.baseRequestData(
          .init(
              scheme: EnvironmentKeys.rootURL.scheme,
              host: EnvironmentKeys.rootURL.host,
              port: EnvironmentKeys.setPort(),
              headers: [
                  "Authorization": ["Bearer "]
              ]
          )
      )
    )

  public typealias EventFetchHandler = @Sendable (EventPageRequest) async throws -> EventsResponse
  public typealias EventCreateHandler = @Sendable (EventInput) async throws -> EventResponse
  public typealias CatrgoriesFetchHandler = @Sendable () async throws -> CategoriesResponse

  public let create: EventCreateHandler
  public let events: EventFetchHandler
  public let categoriesFetch: CatrgoriesFetchHandler

  public init(
    events: @escaping EventFetchHandler,
    create: @escaping EventCreateHandler,
    categoriesFetch: @escaping CatrgoriesFetchHandler
  ) {
      self.events = events
      self.create = create
      self.categoriesFetch = categoriesFetch
  }
}

extension URL {
  public static var empty = Self(string: "")!
}
