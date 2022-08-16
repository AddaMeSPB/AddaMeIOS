//
//  Live.swift
//
//
//  Created by Saroar Khandoker on 11.03.2021.
//

import Combine
import CombineContacts
import ContactClient
import Contacts
import CoreData
import CoreDataStore
import Foundation
import HTTPRequestKit
import InfoPlist
import KeychainService
import PhoneNumberKit
import AddaSharedModels
import URLRouting

public struct ContactAPI {
    public static let build = Self()

    let apiClient: URLRoutingClient<SiteRoute> = .live(
        router: siteRouter.baseRequestData(
            .init(
                scheme: EnvironmentKeys.rootURL.scheme,
                host: EnvironmentKeys.rootURL.host,
                port: EnvironmentKeys.setPort(),
                headers: ["Authorization": ["Bearer \(accessTokenTemp)"]]
            )
        )
    )

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

    public func authorization() async throws -> CNAuthorizationStatus {
        _ = try await self.combineContact.requestAccessAsync(for: .contacts)
        let status = CNContactStore.authorizationStatus(for: .contacts)
        return status
    }

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

        guard let currentUSER: UserOutput = KeychainService.loadCodable(for: .user) else {
            return []
        }

        let fullName = CNContactFormatter.string(from: cnContact, style: .fullName)

        //      var result: [ContactInPut] = [ContactInPut]()
        //
        //      let pns = cnContact.phoneNumbers.map { $0.value.stringValue }
        //      let phoneNumbers = phoneNumberKit.parse(pns)
        //      let rawNumberArray = phoneNumbers.map {
        //          $0.numberString
        //      }
        //      let phoneNumbersCustomDefaultRegion = phoneNumberKit
        //          .parse(rawNumberArray, withRegion: "RU", ignoreType: true)
        //
        //      let mobileNumbers = phoneNumbersCustomDefaultRegion.filter { $0.type == .mobile }
        //
        //      for (index, phone) in mobileNumbers.enumerated() {
        //          result.append(
        //            ContactInPut(
        //                userId: currentUSER.id!,
        //                identifier: cnContact.phoneNumbers[index].identifier,
        //                phoneNumber: phoneNumberKit.format(phone, toType: .e164),
        //                fullName: fullName
        //            )
        //          )
        //      }
        //
        //      return result

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
                    userId: currentUSER.id!,
                    identifier: contact.identifier,
                    phoneNumber: contact.formattedPhoneNumber,
                    fullName: fullName
                )
            }
    }

}

extension ContactClient {
    public static func live(api: ContactAPI) -> Self {
        .init(
            authorization: { return try await api.authorization() },

            buidContacts: { return try await api.buildCustomContactsAsync() },

            getRegisterUsersFromServer: { mobileNumbersInput in
                return try await api.apiClient.decodedResponse(
                    for: .authEngine(
                        .contacts(.getRegisterUsers(inputs: mobileNumbersInput))
                    ),
                    as: [UserOutput].self,
                    decoder: .iso8601
                ).value
            }
        )
    }
}
