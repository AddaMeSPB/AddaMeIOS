//
//  ProfileAction.swift
//  
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import SwiftUI
import SharedModels
import HttpRequest

public enum ProfileAction: Equatable {
  case alertDismissed
  case isUploadingImage
  case showingImagePicker
  case moveToSettingsView
  case moveToAuthView
  
  case fetchMyData
  case uploadAvatar(_ image: UIImage)
  case updateUserName(String, String)
  case createAttachment(_ attachment: Attachment)
  
  case userResponse(Result<User, HTTPError>)
  case attacmentResponse(Result<Attachment, HTTPError>)
  case myEventsResponse(Result<EventResponse, HTTPError>)
  case event(index: Int, action: MyEventAction)
  
  case resetAuthData
}

public enum MyEventAction: Equatable {}

public extension ProfileAction {
  static func view(_ localAction: ProfileView.ViewAction) -> Self {
    switch localAction {
    case .alertDismissed:
      return .alertDismissed
    case .isUploadingImage:
      return .isUploadingImage
    case .showingImagePicker:
      return .showingImagePicker
    case .moveToSettingsView:
      return .moveToAuthView
    case .moveToAuthView:
      return .moveToAuthView
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
    case let .event(index,action):
      return .event(index: index, action: action)
    case .resetAuthData:
      return .resetAuthData
    }
  }
}
