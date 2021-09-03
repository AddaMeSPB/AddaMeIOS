//
//  ProfileAction.swift
//  
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import SwiftUI
import SharedModels
import HttpRequest
import SettingsView

public enum ProfileAction: Equatable {
  case onAppear
  case alertDismissed
  case isUploadingImage
  case showingImagePicker
  case settingsView(isNavigation: Bool)
  case moveToAuthView

  case fetchMyData
  case uploadAvatar(_ image: UIImage)
  case updateUserName(String, String)
  case createAttachment(_ attachment: Attachment)

  case userResponse(Result<User, HTTPError>)
  case attacmentResponse(Result<Attachment, HTTPError>)
  case myEventsResponse(Result<EventResponse, HTTPError>)
  case event(index: EventResponse.Item.ID, action: MyEventAction)
  case settings(SettingsAction)

  case resetAuthData
}

public enum MyEventAction: Equatable {}

public extension ProfileAction {
  // swiftlint:disable:next cyclomatic_complexity
  static func view(_ localAction: ProfileView.ViewAction) -> Self {
    // swiftlint:disable:next superfluous_disable_command
    switch localAction {
    case .onAppear:
      return .onAppear
    case .alertDismissed:
      return .alertDismissed
    case .isUploadingImage:
      return .isUploadingImage
    case .showingImagePicker:
      return .showingImagePicker
    case .moveToSettingsView:
      return .moveToAuthView
    case let .settingsView(isNavigation: present):
      return .settingsView(isNavigation: present)
    case .fetchMyData:
      return .fetchMyData
    case .uploadAvatar(let image):
      return .uploadAvatar(image)
    case let .updateUserName(firstName, lastName):
      return .updateUserName(firstName, lastName)
    case .createAttachment(let attacment):
      return .createAttachment(attacment)
    case .userResponse(let res):
      return .userResponse(res)
    case .attacmentResponse(let res):
      return .attacmentResponse(res)
    case let .event(index, action):
      return .event(index: index, action: action)
    case .resetAuthData:
      return .resetAuthData
    case let .settings(action):
      return .settings(action)
    }
  }
}
