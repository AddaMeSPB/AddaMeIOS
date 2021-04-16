import Foundation

struct Common {}

//// MARK: - Login and Verification request/response
//public struct AuthResponse: Codable, Equatable {
//  
//  public var phoneNumber: String
//  public var attemptId: String?
//  public var code: String?
//  public var isLoggedIn: Bool? = false
//  
//  public init(
//    phoneNumber: String,
//    attemptId: String? = nil,
//    code: String? = nil,
//    isLoggedIn: Bool? = false
//  ) {
//    self.phoneNumber = phoneNumber
//    self.attemptId = attemptId
//    self.code = code
//    self.isLoggedIn = isLoggedIn
//  }
//  
//  public static var draff: Self {
//    .init(phoneNumber: "")
//  }
//  
//}
//
//public struct AuthTokenResponse: Codable {
//  
//  public var accessToken: String
//  public var refreshToken: String
//
//  public init(accessToken: String, refreshToken: String) {
//    self.accessToken = accessToken
//    self.refreshToken = refreshToken
//  }
//  
//}
//
//// MARK: - Login Response
//public struct LoginRes: Codable, Equatable {
//  public static func == (lhs: LoginRes, rhs: LoginRes) -> Bool {
//    return lhs.user == rhs.user
//  }
//  
//  public let status: String
//  public let user: User
//  public let access: AuthTokenResponse
//
//  public init(status: String, user: User, access: AuthTokenResponse) {
//    self.status = status
//    self.user = user
//    self.access = access
//  }
//  
//}
//
//public struct Attachment: Codable {
//  
//  public enum AttachmentType: String, Codable {
//    case file, image, audio, video
//  }
//  
//  public var id: String?
//  public var type: AttachmentType
//  public var userId: String
//  public var imageUrlString: String?
//  public var audioUrlString: String?
//  public var videoUrlString: String?
//  public var fileUrlString: String?
//  public var createdAt, updatedAt: Date?
//  
//  public init(id: String? = nil, type: AttachmentType, userId: String, imageUrlString: String? = nil, audioUrlString: String? = nil, videoUrlString: String? = nil, fileUrlString: String? = nil, createdAt: Date? = nil, updatedAt: Date? = nil) {
//    self.id = id
//    self.type = type
//    self.userId = userId
//    self.imageUrlString = imageUrlString
//    self.audioUrlString = audioUrlString
//    self.videoUrlString = videoUrlString
//    self.fileUrlString = fileUrlString
//    self.createdAt = createdAt
//    self.updatedAt = updatedAt
//  }
//  
//  public static let draff = Self(
//    id: "", type: .image, userId: ""
//  )
//  
//  public static func < (lhs: Attachment, rhs: Attachment) -> Bool {
//    guard let lhsDate = lhs.createdAt, let rhsDate = rhs.createdAt else { return false }
//    return lhsDate > rhsDate
//  }
//
//}
//
//
//// MARK: - User
//public struct User: Codable, Equatable, Hashable, Identifiable {
//  
//  public static var draff: Self {
//    .init(id: UUID().uuidString, phoneNumber: "+79212121211", avatarUrl: nil, firstName: "1st Draff", lastName: "2nd Draff", email: nil, contactIDs: nil, deviceIDs: nil, attachments: nil, createdAt: Date(), updatedAt: Date())
//  }
//  
//  public var id, phoneNumber: String
//  public var avatarUrl, firstName, lastName, email: String?
//  public var contactIDs, deviceIDs: [String]?
//  public var attachments: [Attachment]?
//  public var createdAt, updatedAt: Date
//  
//  public init(id: String, phoneNumber: String, avatarUrl: String? = nil, firstName: String? = nil, lastName: String? = nil, email: String? = nil, contactIDs: [String]? = nil, deviceIDs: [String]? = nil, attachments: [Attachment]? = nil, createdAt: Date, updatedAt: Date) {
//    self.id = id
//    self.phoneNumber = phoneNumber
//    self.avatarUrl = avatarUrl
//    self.firstName = firstName
//    self.lastName = lastName
//    self.email = email
//    self.contactIDs = contactIDs
//    self.deviceIDs = deviceIDs
//    self.attachments = attachments
//    self.createdAt = createdAt
//    self.updatedAt = updatedAt
//  }
//        
//  public func hash(into hasher: inout Hasher) {
//    hasher.combine(id)
//  }
//  
//  public static func == (lhs: User, rhs: User) -> Bool {
//    return
//      lhs.id == rhs.id &&
//      lhs.avatarUrl == rhs.avatarUrl &&
//      lhs.phoneNumber == rhs.phoneNumber &&
//      lhs.firstName == rhs.firstName &&
//      lhs.lastName == rhs.lastName &&
//      lhs.email == rhs.email
//  }
//  
//}
//
//extension User {
//
//  public var lastAvatarURLString: String?  {
//    guard let atchmts = self.attachments  else {
//      return nil
//    }
//    print(#line, atchmts)
//    return atchmts.filter { $0.type == .image }.last?.imageUrlString
//  }
//  
//  public var imageURL: URL? {
//    guard lastAvatarURLString != nil else {
//      return nil
//    }
//    
//    return URL(string: lastAvatarURLString!)!
//  }
//  
//}
