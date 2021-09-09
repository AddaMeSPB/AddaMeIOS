//
//  AttachmentClient.swift
//
//
//  Created by Saroar Khandoker on 27.01.2021.
//

import Combine
import Foundation
import HTTPRequestKit
import SharedModels
import UIKit

public struct AttachmentClient {
  public typealias UpdateUserImageURLHandler = (Attachment, String) -> AnyPublisher<Attachment, HTTPRequest.HRError>
  public typealias UploadImageToS3Handler = (UIImage, String?, String?) -> AnyPublisher<String, HTTPRequest.HRError>

  public let uploadImageToS3: UploadImageToS3Handler
  public let updateUserImageURL: UpdateUserImageURLHandler

  public init(
    uploadImageToS3: @escaping UploadImageToS3Handler,
    updateUserImageURL: @escaping UpdateUserImageURLHandler
  ) {
    self.uploadImageToS3 = uploadImageToS3
    self.updateUserImageURL = updateUserImageURL
  }
}
