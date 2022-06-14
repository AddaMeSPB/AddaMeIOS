//
//  ProfileReducer.swift
//
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import AttachmentClient
import Combine
import ComposableArchitecture
import ComposablePresentation
import ComposableArchitectureHelpers
import EventClient
import Foundation
import HTTPRequestKit
import KeychainService
import SettingsView
import SharedModels
import SwiftUI
import UIKit
import UserClient
import ImagePicker

public func getUserFromKeychain() -> Effect<User, HTTPRequest.HRError> {
  return Effect<User, HTTPRequest.HRError>.future { callBack in
    guard let user: User = KeychainService.loadCodable(for: .user) else {
      print(#line, "missing token")
      return callBack(.failure(HTTPRequest.HRError.missingTokenFromIOS))
    }

    return callBack(.success(user))
  }
}

public let profileReducer = Reducer<
  ProfileState,
  ProfileAction,
  ProfileEnvironment
> {
  state, action, environment in

  func fetchMoreMyEvents() -> Effect<ProfileAction, Never> {
    guard !state.isLoadingPage, state.canLoadMorePages else { return .none }

    state.isLoadingPage = true

    let query = QueryItem(page: "\(state.currentPage)", per: "10")

    return environment.eventClient.events(query, "my")
      .retry(3)
      .receive(on: environment.mainQueue)
      .removeDuplicates()
      .catchToEffect(ProfileAction.myEventsResponse)
  }

  switch action {
  case .onAppear:

    return .merge(
      getUserFromKeychain()
        .flatMap { environment.userClient.userMeHandler($0.id, "\($0.id)") }
        .receive(on: environment.mainQueue)
        .catchToEffect(ProfileAction.userResponse),
      fetchMoreMyEvents()
    )

  case .alertDismissed:
    state.alert = nil
    return .none

  case .isUploadingImage:
    return .none

  case let .settingsView(isNavigation: present):
    state.settingsState = present ? SettingsState() : nil
    return .none

  case .moveToAuthView:

    return .none

  case .fetchMyData:

    return .none

  case let .uploadAvatar(image):
    guard let user: User = KeychainService.loadCodable(for: .user) else {
      return .none
    }

    state.isUploadingImage = true

    return .none

  case let .updateUserName(firstName, lastName):

    return getUserFromKeychain()
      .map { user -> User in
        var user = user
        user.firstName = firstName
        user.lastName = lastName
        return user
      }
      .flatMap { environment.userClient.update($0, "update") }
      .receive(on: environment.mainQueue)
      .catchToEffect(ProfileAction.userResponse)

  case let .createAttachment(attachment):

    return environment.attachmentClient.updateUserImageURL(attachment, "")
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(ProfileAction.attacmentResponse)

  case .resetAuthData:
    AppUserDefaults.save(false, forKey: .isAuthorized)
    KeychainService.save(codable: User?.none, for: .user)
    KeychainService.save(codable: AuthResponse?.none, for: .token)
    KeychainService.logout()
    AppUserDefaults.erase()

    return .none

  case let .userResponse(.success(user)):
    state.user = user
    state.isUploadingImage = false
    if let attachments = user.attachments {
      state.imageURLs = attachments.filter { $0.type == .image }
                                   .compactMap { $0.imageUrlString }

    }
    KeychainService.save(codable: state.user, for: .user)

    return .none

  case let .userResponse(.failure(error)):
    state.isUploadingImage = false
    state.alert = .init(title: TextState(error.description))
    return .none

  case let .attacmentResponse(.success(attachmentResponse)):

    state.isUploadingImage = false
    if let image = attachmentResponse.imageUrlString {
      state.imageURLs.insert(image, at: 0)
    }

    return .none

  case let .attacmentResponse(.failure(error)):
    state.isUploadingImage = false
    state.alert = .init(title: TextState("\(#line) \(error.description)"))
    return .none

  case let .myEventsResponse(.success(events)):

    state.canLoadMorePages = state.myEvents.count < events.metadata.total
    state.isLoadingPage = false
    state.currentPage += 1

    state.myEvents = .init(uniqueElements: events.items)

    return .none

  case let .myEventsResponse(.failure(error)):

    state.alert = .init(
      title: TextState("fetch my event error")
    )

    return .none

  case let .settings(action):
    return .none

  case let .imageUploadResponse(.success(imageURLString)):
    guard let user: User = KeychainService.loadCodable(for: .user) else {
      return .none
    }

    let attachment = Attachment(type: .image, userId: user.id, imageUrlString: imageURLString)

    return environment.attachmentClient.updateUserImageURL(attachment, "")
      .subscribe(on: environment.backgroundQueue)
      .receive(on: environment.mainQueue.animation())
      .catchToEffect()
      .map(ProfileAction.attacmentResponse)

//      .receive(on: environment.mainQueue, anim)
//      .catchToEffect()
//      .map(ProfileAction.attacmentResponse)

  case let .imageUploadResponse(.failure(error)):
    state.isUploadingImage = false
    // handle alert
    return .none

  case .isImagePicker(isPresented: let isPresented):
    state.imagePickerState = isPresented ? ImagePickerState(showingImagePicker: true) : nil
    return .none

  case let .imagePicker(.picked(result: .success(image))):
    state.isUploadingImage = true
    state.imagePickerState = nil
    guard let user: User = KeychainService.loadCodable(for: .user) else {
      return .none
    }

    return AWSS3Helper.uploadImage(image, conversationId: nil, userId: user.id)
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(ProfileAction.imageUploadResponse)

  case .imagePicker(_):
    return .none
  }
}
// .binding()
.debug()
.presenting(
  settingsReducer,
  state: \.settingsState,
  action: /ProfileAction.settings,
  environment: { _ in SettingsEnvironment.live }
)
.presenting(
  imagePickerReducer,
  state: \.imagePickerState,
  action: /ProfileAction.imagePicker,
  environment: { _ in ImagePickerEnvironment.live }
)
