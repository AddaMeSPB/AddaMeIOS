//
//  Attachment.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 19.11.2020.
//

import Foundation

public struct Attachment: Codable, Equatable {
  public enum AttachmentType: String, Codable, Equatable {
    case file, image, audio, video
  }

  public var id: String?
  public var type: AttachmentType
  public var userId: String
  public var imageUrlString: String?
  public var audioUrlString: String?
  public var videoUrlString: String?
  public var fileUrlString: String?
  public var createdAt, updatedAt: Date?

  public init(
    id: String? = nil, type: AttachmentType,
    userId: String, imageUrlString: String? = nil,
    audioUrlString: String? = nil,
    videoUrlString: String? = nil, fileUrlString: String? = nil,
    createdAt: Date? = nil, updatedAt: Date? = nil
  ) {
    self.id = id
    self.type = type
    self.userId = userId
    self.imageUrlString = imageUrlString
    self.audioUrlString = audioUrlString
    self.videoUrlString = videoUrlString
    self.fileUrlString = fileUrlString
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }

  public static let draff = Self(
    id: "", type: .image, userId: ""
  )

  public static func < (lhs: Attachment, rhs: Attachment) -> Bool {
    guard let lhsDate = lhs.createdAt, let rhsDate = rhs.createdAt else { return false }
    return lhsDate > rhsDate
  }
}

extension Attachment: Hashable {}
