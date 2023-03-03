import AddaSharedModels
import Dependencies

public struct UserClient {
    public typealias UserMeHandler = @Sendable (String) async throws -> UserOutput
    public typealias UserUpdateHandler = @Sendable (UserOutput) async throws -> UserOutput
    public typealias UserDeleteHandler = @Sendable (String) async throws -> Bool

    public let userMeHandler: UserMeHandler
    public let update: UserUpdateHandler
    public let delete: UserDeleteHandler

    public init(
        userMeHandler: @escaping UserMeHandler,
        update: @escaping UserUpdateHandler,
        delete: @escaping UserDeleteHandler
    ) {
        self.userMeHandler = userMeHandler
        self.update = update
        self.delete = delete
    }
}

extension UserClient {

    public static var live: UserClient =
        .init(
            userMeHandler: { id in
                @Dependency(\.apiClient) var apiClient
                return try await apiClient.request(
                    for: .authEngine(.users(.user(id: id, route: .find))),
                    as: UserOutput.self,
                    decoder: .iso8601
                )
            },
            update: { userInput in
                @Dependency(\.apiClient) var apiClient
                return try await apiClient.request(
                    for: .authEngine(.users(.update(input: userInput))),
                    as: UserOutput.self,
                    decoder: .iso8601
                )
            },

            delete: { id in
                @Dependency(\.apiClient) var apiClient
                return try await apiClient.data(
                    for: .authEngine(.users(.user(id: id, route: .delete)))
                ).response.isResponseOK()
            }
        )
}

import Foundation
extension URLResponse {
    func isResponseOK() -> Bool {
        if let httpResponse = self as? HTTPURLResponse {
            return (200...299).contains(httpResponse.statusCode)
        }
        return false
    }
}
