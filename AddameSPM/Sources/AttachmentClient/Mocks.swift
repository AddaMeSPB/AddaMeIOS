//
//  Mocks.swift
//
//
//  Created by Saroar Khandoker on 28.01.2021.
//

import Foundation
import AddaSharedModels

// swiftlint:disable line_length superfluous_disable_command
extension AttachmentClient {
  public static let empty = Self(
    uploadImageToS3: { _, _, _ in "" },
    updateUserImageURL: { _ in AttachmentInOutPut.image1 }
  )

  public static let happyPath = Self(
    uploadImageToS3: { _, _, _ in "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/5fabb05d2470c17919b3c0e2_1605792619988.jpeg"
    },
    updateUserImageURL: { _ in AttachmentInOutPut.image2 }
  )
}
