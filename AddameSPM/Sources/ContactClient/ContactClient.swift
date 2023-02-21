import SwiftUI
import Foundation
import Combine
import Contacts

import CombineContacts
import PhoneNumberKit
import AddaSharedModels
import BSON
import Dependencies

public struct ContactClient {
    public typealias AuthorizationStatusHandler = @Sendable () async throws -> CNAuthorizationStatus
    public typealias BuildContactsHandler = @Sendable () async throws-> MobileNumbersInput

    public var authorization: AuthorizationStatusHandler
    public var buidContacts: BuildContactsHandler

    public init(
        authorization: @escaping AuthorizationStatusHandler,
        buidContacts: @escaping BuildContactsHandler
      ) {
        self.authorization = authorization
        self.buidContacts = buidContacts
      }
}

public struct ContactAPI {

    private let phoneNumberKit = PhoneNumberKit()
    private let keysToFetch: [CNKeyDescriptor] = [
        CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
        CNContactPhoneNumbersKey as CNKeyDescriptor,
        CNContactIdentifierKey as CNKeyDescriptor
    ]
    private let combineContact = CombineContacts()
    let region = Locale.current

    private let contactsSubject = PassthroughSubject<[ContactOutPut], Never>()
    var contactsPublisher: AnyPublisher<[ContactOutPut], Never> {
        contactsSubject.eraseToAnyPublisher()
    }

    // MARK: CNAuthorizationStatus
    public func authorization() async throws -> CNAuthorizationStatus {
        _ = try await self.combineContact.requestAccessAsync(for: .contacts)
        let status = CNContactStore.authorizationStatus(for: .contacts)
        return status
    }

    // MARK: RequestAccess
    public var requestAccess: AnyPublisher<Bool, ContactError> {
        return combineContact.requestAccess(for: .contacts)
            .mapError { error in
                error
            }.eraseToAnyPublisher()
    }

    public func requestAccessA() async throws -> Bool {
        do {
            return try await combineContact.requestAccessAsync(for: .contacts)
        } catch {
            print(#line, error)
            throw error
        }
    }

    public func getCNContactsAsync() async throws -> [CNContact] {

        do {
            var contacts: [CNContact] = [CNContact]()

            let cnContainers = try await combineContact.containersAsync(matching: nil)

            for contact in cnContainers {
                let predicate = CNContact.predicateForContactsInContainer(withIdentifier: contact.identifier)
                contacts += try await self.combineContact
                    .unifiedContactsAsync(matching: predicate, keysToFetch: keysToFetch)
            }

            return contacts
        } catch {
            throw error
        }

    }

    public func buildCustomContactsAsync() async throws -> MobileNumbersInput {
        let contacts = try await getCNContactsAsync()
            .map { formatedContactMobile($0) }
            .reduce([ContactInPut](), +)
            .map { $0.phoneNumber }

        return MobileNumbersInput(mobileNumber: contacts)
    }

    private func formatedContactMobile(_ cnContact: CNContact) -> [ContactInPut] {

//        guard let currentUSER: UserOutput = KeychainService.loadCodable(for: .user) else {
//            return []
//        }

        let fullName = CNContactFormatter.string(from: cnContact, style: .fullName)

        return cnContact.phoneNumbers
            .map { cnPhoneNumber in (cnPhoneNumber.identifier, cnPhoneNumber.value.stringValue) }
            .compactMap { (identifier: String, stringValue: String) in
                (
                    identifier: identifier,
                    parsePhoneNumber: try? self.phoneNumberKit.parse(
                        stringValue,
                        withRegion: region.regionCode ?? "RU"
                    )
                )
            }
            .filter {
                $0.parsePhoneNumber != nil && $0.parsePhoneNumber!.type == .mobile
            }
            .map { (identifier: String, parsePhoneNumber: PhoneNumber?) in
                (
                    identifier: identifier,
                    formattedPhoneNumber: self.phoneNumberKit.format(parsePhoneNumber!, toType: .e164)
                )
            }
            .map { contact in
                ContactInPut(
                    userId: ObjectId(), // "currentUSER.id!",
                    identifier: contact.identifier,
                    phoneNumber: contact.formattedPhoneNumber,
                    fullName: fullName
                )
            }
    }

}

extension ContactClient: TestDependencyKey {
    public static let previewValue: Self = .live(api: .init())
    public static let testValue: Self = .authorized
}

extension ContactClient: DependencyKey {
    public static let liveValue: Self = .live(api: .init())
}

extension DependencyValues {
    public var contactClient: ContactClient {
        get { self[ContactClient.self] }
        set { self[ContactClient.self] = newValue }
    }
}

extension ContactClient {
    public static func live(api: ContactAPI) -> Self {
        .init(
            authorization: { return try await api.authorization() },
            buidContacts: { return try await api.buildCustomContactsAsync() }
        )
    }
}


// import Combine
// import Contacts
//
// class Contact: ObservableObject {
//  var dispose = Set<AnyCancellable>()
//  let contactStore = CNContactStore()
//  @Published var invalidPermission: Bool = false
//
//  var authorizationStatus: AnyPublisher<CNAuthorizationStatus, Never> {
//    Future<CNAuthorizationStatus, Never> { promise in
//      self.contactStore.requestAccess(for: .contacts) { (_, _) in
//        let status = CNContactStore.authorizationStatus(for: .contacts)
//        promise(.success(status))
//      }
//    }
//    .eraseToAnyPublisher()
//  }
//
//  func requestAccess() {
//    self.authorizationStatus
//      .receive(on: RunLoop.main)
//      .map { $0 == .denied || $0 == .restricted }
//      .assign(to: \.invalidPermission, on: self)
//      .store(in: &dispose)
//  }
// }
//
// struct ContactView: View {
//  @ObservedObject var contact = Contact()
//
//  var body: some View {
//    VStack {
//      Button(action: {
//        // if pressed button, request contact permissions
//        self.contact.requestAccess()
//      }) {
//        Text("Request access to Contacts")
//      }
//    }
//    .alert(isPresented: self.$contact.invalidPermission) {
//      Alert(
//        title: Text("TITLE"),
//        message: Text("Please go to Settings and turn on the permissions"),
//        primaryButton: .cancel(Text("Cancel")),
//        secondaryButton: .default(Text("Settings"), action: {
//          if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//          }
//        }))
//    }
//  }
// }
