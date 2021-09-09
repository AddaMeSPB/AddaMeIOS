import SwiftUI

public struct ActivityView: UIViewControllerRepresentable {
  public var activityItems: [Any]

  public init(activityItems: [Any]) {
    self.activityItems = activityItems
  }

  public func makeUIViewController(context _: Context) -> UIActivityViewController {
    let controller = UIActivityViewController(
      activityItems: activityItems,
      applicationActivities: nil
    )
    return controller
  }

  public func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}
