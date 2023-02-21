import Foundation

// swiftlint:disable line_length superfluous_disable_command
extension AttachmentS3Client {
  public static let empty = Self(
    uploadImageToS3: { _, _, _ in "" }
  )

  public static let happyPath = Self(
    uploadImageToS3: { _, _, _ in "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/5fabb05d2470c17919b3c0e2_1605792619988.jpeg"
    }
  )
}
