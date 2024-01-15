import Foundation
import Combine
import URLRouting
import InfoPlist
import FoundationExtension
import Dependencies
import AppConfiguration
import KeychainClient
import Build
import AddaSharedModels

public typealias APIClient = URLRoutingClient<SiteRoute>

public enum APIClientKey: TestDependencyKey {
    public static let testValue = APIClient.failing
}

extension APIClientKey: DependencyKey {
    public static let baseURL = DependencyValues._current.appConfiguration.apiURL
    public static let liveValue: APIClient = APIClient.live(
        router: siteRouter.baseURL(APIClientKey.baseURL)
    )
}

extension DependencyValues {
    public var apiClient: APIClient {
        get { self[APIClientKey.self] }
        set { self[APIClientKey.self] = newValue }
    }
}

public enum APIError: Error {
    case serviceError(statusCode: Int, APIErrorPayload)
    case unknown

    init(error: Error) {
        if let apiError = error as? APIError {
            self = apiError
        } else {
            self = .unknown
        }
    }
}

extension APIError: Equatable {

}

public struct APIErrorPayload: Codable, Equatable {
    let reason: String?
}

extension APIClient {

    @available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
    public func request<Value: Decodable>(
        for route: Route,
        as type: Value.Type = Value.self,
        decoder: JSONDecoder = .init()
    ) async throws -> Value {
        guard var request = try? siteRouter.baseURL(APIClientKey.baseURL).request(for: route)
        else { throw URLError(.badURL) }
        request.setHeaders()

        let (data, response) = try await URLSession.shared.data(for: request)

//        #if DEBUG
//        #endif

        if let statusCode = (response as? HTTPURLResponse)?.statusCode {
            switch statusCode {
            case 200 ..< 300:
                return try decoder.decode(Value.self, from: data)

            case 400 ..< 500:
                let payload = try decoder.decode(APIErrorPayload.self, from: data)
                throw APIError.serviceError(statusCode: statusCode, payload)

            default:
                throw APIError.unknown
            }
        } else {
            throw APIError.unknown
        }
    }
}
