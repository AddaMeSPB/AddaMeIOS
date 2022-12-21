// import Combine
// import Foundation
// import AddaSharedModels
// import URLRouting
// import InfoPlist
//
// public struct UserClient {
//
//    static public let apiClient: URLRoutingClient<SiteRoute> = .live(
//      router: siteRouter.baseRequestData(
//          .init(
//              scheme: EnvironmentKeys.rootURL.scheme,
//              host: EnvironmentKeys.rootURL.host,
//              port: EnvironmentKeys.setPort(),
//              headers: ["Authorization": ["Bearer "]]
//          )
//      )
//    )
//
//    public typealias UserMeHandler = @Sendable (String) async throws -> UserOutput
//    public typealias UserUpdateHandler = @Sendable (UserOutput) async throws -> UserOutput
//    public typealias UserDeleteHandler = @Sendable (String) async throws -> Bool
//
//    public let userMeHandler: UserMeHandler
//    public let update: UserUpdateHandler
//    public let delete: UserDeleteHandler
//
//    public init(
//        userMeHandler: @escaping UserMeHandler,
//        update: @escaping UserUpdateHandler,
//        delete: @escaping UserDeleteHandler
//    ) {
//        self.userMeHandler = userMeHandler
//        self.update = update
//        self.delete = delete
//    }
// }
