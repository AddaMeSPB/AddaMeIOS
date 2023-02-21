//
//  ContactsReducer.swift
//
//
//  Created by Saroar Khandoker on 12.05.2021.
//


import ChatView
import Combine
import ComposableArchitecture
import ComposableArchitectureHelpers
import CoreData
import CoreDataStore
import AddaSharedModels
import SwiftUI
import URLRouting
import BSON
import Contacts
import ContactClient
import APIClient

public struct ContactsReducer: ReducerProtocol {
    public struct State: Equatable {
        public init(
            alert: AlertState<ContactsReducer.State.Action>? = nil,
            contacts: IdentifiedArrayOf<ContactRow.State> = [],
            isAuthorizedContacts: Bool = false,
            invalidPermission: Bool = false,
            isLoading: Bool = false,
            isActivityIndicatorVisible: Bool = false
        ) {
            self.alert = alert
            self.contacts = contacts
            self.isAuthorizedContacts = isAuthorizedContacts
            self.invalidPermission = invalidPermission
            self.isLoading = isLoading
            self.isActivityIndicatorVisible = isActivityIndicatorVisible
        }

      public var alert: AlertState<Action>?
      public var contacts: IdentifiedArrayOf<ContactRow.State> = []
      public var isAuthorizedContacts: Bool = false
      public var invalidPermission: Bool = false
      public var isLoading: Bool = false
      public var isActivityIndicatorVisible: Bool = false

      public enum Action: Equatable {
        case didChangeAuthorization(CNAuthorizationStatus)
      }


    }

    public enum Action: Equatable {
      case onAppear
      case alertDismissed
      case contact(id: String?, action: ContactRow.Action)
      case contactsAuthorizationStatus(CNAuthorizationStatus)
      case contactsResponse(TaskResult<[ContactOutPut]>)

      case moveToChatRoom(Bool)
      case chatWith(name: String, phoneNumber: String)
    }

    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.contactClient) var contactClient
    @Dependency(\.apiClient) var apiClient

    public init() {}

    public var body: some ReducerProtocol<State, Action> {

//        contactRowReducer
//          .forEach(
//            state: \ContactsState.contacts,
//            action: /ContactsAction.contact(id:action:),
//            environment: { _ in ContactRowEnvironment() }
//          ),

        Reduce(self.core)
    }

    func core(state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .onAppear:

            state.isLoading = true
            return .task {
                .contactsAuthorizationStatus(
                    try await contactClient.authorization()
                )
            }

        case .alertDismissed:
          state.alert = nil
          return .none

        case let .contactsResponse(.success(contacts)):
          print(#line, contacts)
          state.isLoading = false
          let contactRowStates = contacts.map { ContactRow.State(contact: $0) }
          state.contacts = .init(uniqueElements: contactRowStates)
          return .none

        case let .contactsResponse(.failure(error)):
          state.alert = .init(
            title: TextState("Something went worng please try again \(error.localizedDescription)"))
          return .none

        case let .contactsAuthorizationStatus(status):
            switch status {
            case .authorized:
                return .task {
                    do {
                        let contacts = try await contactClient.buidContacts()
                        let defaultContacts = Set(contacts.mobileNumber).sorted()
                        let afterRemoveDuplicationContacts = MobileNumbersInput(mobileNumber: defaultContacts)
                        let userOutputs = try await apiClient.request(
                            for: .authEngine(
                                .contacts(.getRegisterUsers(inputs: afterRemoveDuplicationContacts))
                            ),
                            as: [UserOutput].self,
                            decoder: .iso8601
                        )

                        let contactsOutPut = userOutputs.map { user in
                            ContactOutPut(
                                id: ObjectId(),
                                userId: user.id,
                                identifier: user.id.hexString,
                                phoneNumber: user.phoneNumber ?? "",
                                fullName: user.fullName,
                                avatar: user.lastAvatarURLString,
                                isRegister: true
                            )
                        }

                        return .contactsResponse(.success(contactsOutPut))

                    } catch let error as URLRoutingDecodingError {
                        debugPrint(#line, error.response, error.localizedDescription)
                      // use error.response or error.data to surface errors to user
                        return .contactsResponse(
                            .failure("cant send or or server error")
                        )
                    } catch {
                        return .contactsResponse(
                            .failure("cant send or or server error")
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

}
