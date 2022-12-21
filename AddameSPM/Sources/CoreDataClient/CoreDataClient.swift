import Combine
import ContactClient
import ContactClientLive
import CoreData
import CoreDataStore
import Foundation
import HTTPRequestKit
import AddaSharedModels
import BSON

public final class CoreDataClient {
  public var contactClient: ContactClient
  public var contacts = [ContactOutPut]()

  public init(contactClient: ContactClient) {
    self.contactClient = contactClient
  }

  public func getContacts(contacts: MobileNumbersInput) async throws -> [ContactOutPut] {
      let defaultContacts = Set(contacts.mobileNumber).sorted()
      let afterRemoveDuplicationContacts = MobileNumbersInput(mobileNumber: defaultContacts)
      return try await contactClient.getRegisterUsersFromServer(afterRemoveDuplicationContacts)
          .map { user in
              return ContactOutPut(
              id: ObjectId(),
              userId: user.id!,
              identifier: user.id!.hexString,
              phoneNumber: user.phoneNumber ?? "",
              fullName: user.fullName,
              avatar: user.lastAvatarURLString,
              isRegister: true
            )
          }
  }
}
