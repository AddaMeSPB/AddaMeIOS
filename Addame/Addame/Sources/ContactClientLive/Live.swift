//
//  Live.swift
//
//
//  Created by Saroar Khandoker on 11.03.2021.
//

import Combine
import Foundation
import ContactClient
import HttpRequest
import SharedModels
import InfoPlist
import KeychainService
import Contacts
import CoreData
import PhoneNumberKit
import CombineContacts
import CoreDataStore

func token() -> AnyPublisher<String, HTTPError> {
  guard let token: AuthTokenResponse = KeychainService.loadCodable(for: .token) else {
    print(#line, "not Authorized Token are missing")
    return Fail(error: HTTPError.missingTokenFromIOS )
      .eraseToAnyPublisher()
  }

  return Just(token.accessToken)
    .setFailureType(to: HTTPError.self)
    .eraseToAnyPublisher()
}

public struct ContactAPI {

  public static let build = Self()
  private var baseURL: URL {
    EnvironmentKeys.rootURL.appendingPathComponent("/contacts/")
  }

  private let contactStore = CNContactStore()
  private let phoneNumberKit = PhoneNumberKit()
  private let keysToFetch: [CNKeyDescriptor] = [
    CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
    CNContactPhoneNumbersKey as CNKeyDescriptor,
    CNContactIdentifierKey as CNKeyDescriptor
  ]
  private let combineContact = CombineContacts()
  let region = Locale.current

  private let contactsSubject = PassthroughSubject<[Contact], Never>()
  var contactsPublisher: AnyPublisher<[Contact], Never> {
    contactsSubject.eraseToAnyPublisher()
  }

  public func authorization() -> AnyPublisher<CNAuthorizationStatus, Never> {
    Future<CNAuthorizationStatus, Never> { promise in
      self.contactStore.requestAccess(for: .contacts) { _, _ in
        let status = CNContactStore.authorizationStatus(for: .contacts)
        promise(.success(status))
      }
    }
    .eraseToAnyPublisher()
  }

  public var requestAccess: AnyPublisher<Bool, ContactError> {
    return self.combineContact.requestAccess(for: .contacts)
      .mapError { error in
        return error
      }.eraseToAnyPublisher()
  }

  public func getCNContacts() -> AnyPublisher<[CNContact], ContactError> {
    return self.combineContact.containers(matching: nil)
      .flatMap { containers -> AnyPublisher<CNContainer, ContactError> in
        return containers
          .publisher
          .setFailureType(to: ContactError.self)
          .eraseToAnyPublisher()
      }
      .map { CNContact.predicateForContactsInContainer(withIdentifier: $0.identifier) }
      .flatMap { predicate in
        self.combineContact.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
      }
      .mapError {
        return $0
      }
      .eraseToAnyPublisher()
  }

  public func buildCustomContacts() -> AnyPublisher<[Contact], ContactError> {

    return self.getCNContacts()
      .flatMap { cnContacts -> AnyPublisher<CNContact, ContactError> in
        return cnContacts
          .publisher
          .setFailureType(to: ContactError.self)
          .eraseToAnyPublisher()
      }
      .map { formatedContactMobile($0) }
      .reduce([Contact](), +)
      .removeDuplicates()
      .mapError {
        return $0
      }
      .eraseToAnyPublisher()
  }

  private func formatedContactMobile(_ cnContact: CNContact) -> [Contact] {
    guard let currentUSER: User = KeychainService.loadCodable(for: .user) else {
      return []
    }

    let fullName = CNContactFormatter.string(from: cnContact, style: .fullName)

    return cnContact.phoneNumbers
      .map { ($0.identifier, $0.value.stringValue) }
      .compactMap {
        ($0.0, try? self.phoneNumberKit.parse($0.1, withRegion: region.regionCode ?? "RU"))
      }
      .filter({ $0.1?.type == .mobile })
      .map {
        return (identifier: $0.0, formattedPhoneNumber: self.phoneNumberKit.format($0.1!, toType: .e164))
      }
      .map {
        return Contact(
          identifier: $0.identifier,
          userId: currentUSER.id, phoneNumber: $0.formattedPhoneNumber,
          fullName: fullName
        )
      }
  }

  private func fetchUsers(by contacts: [Contact]) -> AnyPublisher<[User], HTTPError> {
    return token().flatMap { token -> AnyPublisher<[User], HTTPError> in
      let builder: HttpRequest = .build(
        baseURL: baseURL,
        method: .post,
        authType: .bearer(token: token),
        path: "",
        contentType: .json,
        dataType: .encodable(input: contacts, encoder: .init() )
      )

      return builder.send(scheduler: RunLoop.main)
        .catch { (error: HTTPError) -> AnyPublisher<[User], HTTPError> in
          return Fail(error: error).eraseToAnyPublisher()
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    .catch { (error: HTTPError) -> AnyPublisher<[User], HTTPError> in
      return Fail(error: error).eraseToAnyPublisher()
    }
    .catch { (error: HTTPError) -> AnyPublisher<[User], HTTPError> in
      return Fail(error: error).eraseToAnyPublisher()
    }
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
  }

  public func getRegUsers(by contacts: [Contact]) -> AnyPublisher<[User], HTTPError> {
    return self.buildCustomContacts()
      .mapError { contactError -> HTTPError in
        return HTTPError.custom("from contactError to httpError", contactError)
      }
      .flatMapLatest { contacts -> AnyPublisher<[User], HTTPError> in
        self.fetchUsers(by: contacts)
      }
      .eraseToAnyPublisher()
  }

}

extension ContactClient {
  public static func live(api: ContactAPI) -> Self {
    .init(
      authorization: api.authorization,
      buidContacts: api.buildCustomContacts,
      getRegisterUsersFromServer: api.getRegUsers(by:)
    )
  }
}

//
// struct AnyObserver<Output, Failure: Error> {
//  let onNext: ((Output) -> Void)
//  let onError: ((Failure) -> Void)
//  let onComplete: (() -> Void)
// }
//
// struct Disposable {
//  let dispose: () -> Void
// }
//
// extension AnyPublisher {
//  static func create(subscribe: @escaping (AnyObserver<Output, Failure>) -> Disposable) -> Self {
//    let subject = PassthroughSubject<Output, Failure>()
//    var disposable: Disposable?
//    return subject
//      .handleEvents(receiveSubscription: { subscription in
//        disposable = subscribe(AnyObserver(
//          onNext: { output in subject.send(output) },
//          onError: { failure in subject.send(completion: .failure(failure)) },
//          onComplete: { subject.send(completion: .finished) }
//        ))
//      }, receiveCancel: { disposable?.dispose() })
//      .eraseToAnyPublisher()
//  }
// }
