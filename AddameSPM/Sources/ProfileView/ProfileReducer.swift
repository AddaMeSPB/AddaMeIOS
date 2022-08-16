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
import AddaSharedModels
import SwiftUI
import UIKit
import UserClient
import ImagePicker
import MyEventsView

public let profileReducer = Reducer<
  ProfileState,
  ProfileAction,
  ProfileEnvironment>.combine(
    myEventsReducer.pullback(
        state: \.myEventsState,
        action: /ProfileAction.myEvents,
        environment: { _ in MyEventsEnvironment.live }
 ),
  Reducer {state, action, environment in

  switch action {
  case .onAppear:

      guard let currentUSER: UserOutput = KeychainService.loadCodable(for: .user),
                let userId = currentUSER.id else {
        // assertionFailure("current user is missing")
        return .none
      }

      return .task {
          do {
              return ProfileAction.userResponse(
                .success(try await environment.userClient.userMeHandler(userId.hexString))
              )
          } catch {
              return ProfileAction.userResponse(
                .failure(HTTPRequest.HRError.custom("fetch user error", error))
              )
          }
      }

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
    guard let user: UserOutput = KeychainService.loadCodable(for: .user) else {
      return .none
    }

    state.isUploadingImage = true

    return .none

  case let .updateUserName(firstName, lastName):

      return .task {
          do {
              guard var currentUSER: UserOutput = KeychainService.loadCodable(for: .user) else {
                // assertionFailure("current user is missing")
                  return ProfileAction.userResponse(
                    .failure(HTTPRequest.HRError.custom("cant find user from KeychainService", nil))
                  )
              }

              currentUSER.firstName = firstName
              currentUSER.lastName = lastName

              return ProfileAction.userResponse(.success(try await environment.userClient.update(currentUSER)))
          } catch {
              return ProfileAction.userResponse(
                .failure(HTTPRequest.HRError.custom("cant update user \(error)", error))
              )
          }
      }

  case let .createAttachment(attachment):

      return .task {
          do {
              return ProfileAction.attacmentResponse(
                .success(try await environment.attachmentClient.updateUserImageURL(attachment))
              )
          } catch {
              return ProfileAction.attacmentResponse(
                .failure(
                    HTTPRequest.HRError
                        .custom("cant upload image data error: \(error)", error)
                )
              )
          }

      }

//    return environment.attachmentClient.updateUserImageURL(attachment, "")
//      .receive(on: environment.mainQueue)
//      .catchToEffect()
//      .map(ProfileAction.attacmentResponse)

  case .resetAuthData:
    AppUserDefaults.save(false, forKey: .isAuthorized)
    KeychainService.save(codable: UserOutput?.none, for: .user)
    KeychainService.save(codable: VerifySMSInOutput?.none, for: .token)
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

  case let .settings(action):
    return .none

  case let .imageUploadResponse(.success(imageURLString)):
        guard let user: UserOutput = KeychainService.loadCodable(for: .user) else {
          return .none
        }

      let attachmentInput = AttachmentInOutPut(type: .image, userId: user.id, imageUrlString: imageURLString)

      return .task {
          do {
              return ProfileAction.attacmentResponse(
                .success(try await environment.attachmentClient.updateUserImageURL(attachmentInput))
              )
          } catch {
              return ProfileAction.attacmentResponse(
                .failure(
                    HTTPRequest.HRError.custom("cant upload attachment", error)
                )
              )
          }
      }

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
    guard let user: UserOutput = KeychainService.loadCodable(for: .user) else {
      return .none
    }

      return .task {
          do {
              return ProfileAction.imageUploadResponse(
                .success(try await environment.attachmentClient.uploadImageToS3(image, nil, user.id?.hexString))
              )
          } catch {
              return ProfileAction.imageUploadResponse(
                .failure(
                    HTTPRequest.HRError.custom("cant upload image to S3 server", error)
                )
              )
          }
      }

  case .imagePicker(_):
    return .none
  case .myEvents(let action):
      return .none
  }
  })
// .binding()
.debug()
.presenting(
  settingsReducer,
  state: .keyPath(\.settingsState),
  id: .notNil(),
  action: /ProfileAction.settings,
  environment: { _ in SettingsEnvironment.live }
)
.presenting(
  imagePickerReducer,
  state: .keyPath(\.imagePickerState),
  id: .notNil(),
  action: /ProfileAction.imagePicker,
  environment: { _ in ImagePickerEnvironment.live }
)
