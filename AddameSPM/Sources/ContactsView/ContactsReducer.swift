//
//  ContactsReducer.swift
//
//
//  Created by Saroar Khandoker on 12.05.2021.
//

import ChatClient
import ChatClientLive
import ChatView
import Combine
import ComposableArchitecture
import ComposableArchitectureHelpers
import CoreData
import CoreDataStore
import HTTPRequestKit
import AddaSharedModels
import SwiftUI
import WebSocketClient
import WebSocketClientLive
import URLRouting
import BSON

public let contactsReducer: Reducer<ContactsState, ContactsAction, ContactsEnvironment> = .combine(
  contactRowReducer
    .forEach(
      state: \ContactsState.contacts,
      action: /ContactsAction.contact(id:action:),
      environment: { _ in ContactRowEnvironment() }
    ),

  .init { state, action, environment in

    switch action {
    case .onAppear:
      state.isLoading = true
        return .task {
            do {
                let status = try await environment.contactClient.authorization()
                return ContactsAction.contactsAuthorizationStatus(status)
            } catch let error as URLRoutingDecodingError {
              // use error.response or error.data to surface errors to user
                return ContactsAction.alertDismissed
            } catch {
                let status = try await environment.contactClient.authorization()
                return ContactsAction.contactsAuthorizationStatus(status)
            }
        }

    case .alertDismissed:
      state.alert = nil
      return .none

    case let .contactsResponse(.success(contacts)):
      print(#line, contacts)
      state.isLoading = false
      let contactRowStates = contacts.map { ContactRowState(contact: $0) }
      state.contacts = .init(uniqueElements: contactRowStates)
      return .none

    case let .contactsResponse(.failure(error)):
      state.alert = .init(
        title: TextState("Something went worng please try again \(error.description)"))
      return .none

    case let .contactsAuthorizationStatus(status):
        switch status {
        case .authorized:
            return .task {
                do {
                    let contacts = try await environment.contactClient.buidContacts()
                    let defaultContacts = Set(contacts.mobileNumber).sorted()
                    let afterRemoveDuplicationContacts = MobileNumbersInput(mobileNumber: defaultContacts)
                    let userOutputs = try await environment.contactClient
                        .getRegisterUsersFromServer(afterRemoveDuplicationContacts)

                    let contactsOutPut = userOutputs.map { user in
                        ContactOutPut(
                            id: ObjectId(),
                            userId: user.id!,
                            identifier: user.id!.hexString,
                            phoneNumber: user.phoneNumber ?? "",
                            fullName: user.fullName,
                            avatar: user.lastAvatarURLString,
                            isRegister: true
                        )
                    }

                    return ContactsAction.contactsResponse(.success(contactsOutPut))

                } catch let error as URLRoutingDecodingError {
                    debugPrint(#line, error.response, error.localizedDescription)
                  // use error.response or error.data to surface errors to user
                    return ContactsAction.contactsResponse(
                        .failure(HTTPRequest.HRError.custom("cant send or or server error", error))
                    )
                } catch {
                    return ContactsAction.contactsResponse(
                        .failure(HTTPRequest.HRError.custom("cant send or or server error", error))
                    )
                }
            }

        case .notDetermined:
            state.alert = .init(title: TextState("Permission notDetermined"))
            return .none
        case .denied:
            state.alert = .init(title: TextState("Permission denied"))
            return .none
        case .restricted:
            state.alert = .init(title: TextState("Permission restricted"))
            return .none
        @unknown default:
            state.alert = .init(title: TextState("Permission unknow"))
            return .none
        }

    case let .contact(id: id, action: action): return .none
    case let .moveToChatRoom(present): return .none
    case let .chatWith(name: name, phoneNumber: phoneNumber): return .none

    }
  }
)
