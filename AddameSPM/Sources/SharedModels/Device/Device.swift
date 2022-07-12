public struct Device: Codable, Equatable {
    public var id: String?
    public var ownerId: String
    public var name: String
    public var model: String?
    public var osVersion: String?
    public var token: String
    public var voipToken: String
    public var createAt, updatedAt: String?

    public init(
        id: String? = nil,
        ownerId: String,
        name: String,
        model: String? = nil,
        osVersion: String? = nil,
        token: String,
        voipToken: String,
        createAt: String? = nil,
        updatedAt: String? = nil
    ) {
        self.id = id
        self.ownerId = ownerId
        self.name = name
        self.model = model
        self.osVersion = osVersion
        self.token = token
        self.voipToken = voipToken
        self.createAt = createAt
        self.updatedAt = updatedAt
    }
}

extension Device {
    public static let empty: Device = .init(
        id: "", ownerId: "", name: "", model: "", osVersion: "",
        token: "", voipToken: "", createAt: nil, updatedAt: nil
    )

    public static let happyPath: Device = .init(
        id: "5fc4e85f7557200b8c8f0dfb", ownerId: "5fabb1ebaa5f5774ccfe48c3", name: "iPhone",
        model: "iPhone", osVersion: "14.2", token: "58ca32667055d845b8db0b2a5b7a7684af6960d6af8f7ac89a558ec1dd72c4a0",
        voipToken: "c8117f3f9d0902850e7c7b84ab0082aa995c2fd1e8873a698cc0dd3e2661912c", createAt: nil, updatedAt: nil
    )
}
