//
//  ProfileAction.swift
//
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import HTTPRequestKit
import SettingsView
import AddaSharedModels
import SwiftUI
import ImagePicker
import MyEventsView

public enum ProfileAction: Equatable {
  case onAppear
  case alertDismissed
  case isUploadingImage
  case isImagePicker(isPresented: Bool)
  case settingsView(isNavigation: Bool)
  case moveToAuthView

  case fetchMyData
  case uploadAvatar(_ image: UIImage)
  case updateUserName(String, String)
  case createAttachment(_ attachment: AttachmentInOutPut)

  case imageUploadResponse(Result<String, HTTPRequest.HRError>)
  case userResponse(Result<UserOutput, HTTPRequest.HRError>)
  case attacmentResponse(Result<AttachmentInOutPut, HTTPRequest.HRError>)
  case myEvents(MyEventsAction)
  case settings(SettingsAction)
  case imagePicker(action: ImagePickerAction)

  case resetAuthData
}

extension ProfileAction {
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
    case let .settingsView(isNavigation: present):
      return .settingsView(isNavigation: present)
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
    case let .settings(action):
      return .settings(action)
    case let .imagePicker(action: action):
      return .imagePicker(action: action)
    case .resetAuthData:
      return .resetAuthData

    }
  }
}
