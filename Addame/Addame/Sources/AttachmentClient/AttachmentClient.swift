//
//  AttachmentClient.swift
//
//
//  Created by Saroar Khandoker on 27.01.2021.
//

import Foundation
import Combine
import HttpRequest
import SharedModels

public struct AttachmentClient {

  public typealias UserImageUploadHandler = (Attachment) -> AnyPublisher<Attachment, HTTPError>
  public let uploadAvatar: UserImageUploadHandler

  public init(uploadAvatar: @escaping UserImageUploadHandler) {
    self.uploadAvatar = uploadAvatar
  }
}
