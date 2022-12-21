// import Foundation
// import FoundationExtension
// import AddaSharedModels
// import InfoPlist
// import URLRouting
//
// public struct DeviceClient {
//
//    public static let apiClient: URLRoutingClient<SiteRoute> = .live(
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
//    public typealias DeviceCUHandler = @Sendable (DeviceInOutPut) async throws -> DeviceInOutPut
//
//    public let dcu: DeviceCUHandler
//
//    public init(dcu: @escaping DeviceCUHandler) {
//        self.dcu = dcu
//    }
//
// }
//
//// Mock
// extension DeviceClient {
//    public static let empty = Self(
//        dcu: { _ in .empty }
//    )
//
//    public static let happyPath = Self(
//        dcu: { _ in .draff }
//    )
// }
//
//// Live
// extension DeviceClient {
//    public static var live: DeviceClient = .init(
//        dcu: { input in
//            return try await DeviceClient.apiClient.decodedResponse(
//                for: .authEngine(.devices(.createOrUpdate(input: input))),
//                as: DeviceInOutPut.self,
//                decoder: .iso8601
//            ).value
//        }
//    )
//
// }
