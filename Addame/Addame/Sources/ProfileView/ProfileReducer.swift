//
//  ProfileReducer.swift
//  
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import ComposableArchitecture
import Foundation
import Combine
import SwiftUI

import HttpRequest
import UserClient
import EventClient
import KeychainService
import AttachmentClient
import SharedModels

public func getUserFromKeychain() -> Effect<User, HTTPError> {

  return Effect<User, HTTPError>.future { callBack in
    guard let user: User = KeychainService.loadCodable(for: .user) else {
      print(#line, "missing token")
      return callBack(.failure(HTTPError.missingTokenFromIOS))
    }

    return callBack(.success(user))
  }

}

// public let eventReducer = Reducer<EventsState, EventsAction, EventsEnvironment>.combine(
//  eventFormReducer.optional().pullback(
//    state: \.eventForm,
//    action: /EventsAction.eventForm,
//    environment: { _ in () }
//  ),
//  Reducer { state, action, environment in
//    struct LocationManagerId: Hashable {}
//

public let profileReducer = Reducer<ProfileState, ProfileAction, ProfileEnvironment> { state, action, environment in

  func fetchMoreMyEvents() -> Effect<ProfileAction, Never> {

    guard !state.isLoadingPage && state.canLoadMorePages else { return .none }

    state.isLoadingPage = true

    let query = QueryItem(page: "\(state.currentPage)", per: "10")

    return environment.eventClient.events(query, "my")
      .retry(3)
      .receive(on: environment.mainQueue.animation(.default))
      .removeDuplicates()
      .catchToEffect()
      .map(ProfileAction.myEventsResponse)
  }

  switch action {
  case .onAppear:
    return fetchMoreMyEvents()

  case .alertDismissed:
    state.alert = nil
    return .none

  case .isUploadingImage:

    return .none
  case .showingImagePicker:

    return .none

  case .moveToSettingsView:

    return .none

  case .moveToAuthView:

    return .none

  case .fetchMyData:

    return getUserFromKeychain()
      .flatMap { environment.userClient.userMeHandler($0.id, "\($0.id)") }
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(ProfileAction.userResponse)

  case .uploadAvatar(let image):
    guard let user: User = KeychainService.loadCodable(for: .user) else {
      return .none
    }

    state.isUploadingImage = true

    //    AWSS3Helper.uploadImage(image, conversationId: nil, userId: me.id) { imageURLString in
    //      guard imageURLString != nil else {
    //        state.isUploadingImage = false
    //        return
    //      }
    //
    //      state.isUploadingImage = true
    //      let attachment = Attachment(type: .image, userId: me.id, imageUrlString: imageURLString)
    //
    //      /// think about how to send attachment
    //    }
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
      .catchToEffect()
      .map(ProfileAction.userResponse)

  case .createAttachment(let attachment):

    return environment.attachmentClient.uploadAvatar(attachment)
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

  case .userResponse(.success(let user)):
    state.user = user
    state.isUploadingImage = false

    return .none

  case .userResponse(.failure(let error)):
    state.isUploadingImage = false
    state.alert = .init(title: TextState( "\(#line) \(error.description)"))
    return .none

  case .attacmentResponse(.success(let attachmentResponse)):

    state.isUploadingImage = false
    if var userAttacments = state.user.attachments, !userAttacments.contains(attachmentResponse) {
      userAttacments.append(attachmentResponse)
    }

    return .none

  case .attacmentResponse(.failure(let error)):
    state.isUploadingImage = false
    state.alert = .init(title: TextState( "\(#line) \(error.description)"))
    return .none

  case .myEventsResponse(.success(let events)):

    state.canLoadMorePages = state.myEvents.count < events.metadata.total
    state.isLoadingPage = false
    state.currentPage += 1

    state.myEvents = .init(uniqueElements: events.items)

    return.none

  case .myEventsResponse(.failure(let error)):

    state.alert = .init(
      title: TextState("fetch my event error")
    )

    return .none
  }
}
