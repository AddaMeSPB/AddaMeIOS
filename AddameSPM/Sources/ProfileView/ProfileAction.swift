
import AddaSharedModels
import SwiftUI
import ImagePicker
import MyEventsView

extension Profile.Action {
  // swiftlint:disable:next cyclomatic_complexity
  public static func view(_ localAction: ProfileView.ViewAction) -> Self {
    // swiftlint:disable:next superfluous_disable_command
    switch localAction {
    case .alertDismissed:
      return .alertDismissed
    case .isUploadingImage:
      return .isUploadingImage
    case let .isImagePicker(isPresented: presented):
      return .isImagePicker(isPresented: presented)
    case .moveToSettingsView:
      return .moveToAuthView
    case let .settingsView(isNavigate: present):
      return .settingsView(isNavigate: present)
    case .fetchMyData:
      return .fetchMyData
    case let .uploadAvatar(image):
      return .uploadAvatar(image)
    case let .updateUserName(firstName, lastName):
      return .updateUserName(firstName, lastName)
    case let .createAttachment(attacment):
      return .createAttachment(attacment)
    case let .userResponse(res):
      return .userResponse(res)
//    case let .settings(action):
//      return .settings(action)
    case let .imagePicker(action: action):
      return .imagePicker(action: action)
    case .resetAuthData:
      return .resetAuthData
    }
  }
}
