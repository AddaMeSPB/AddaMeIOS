import CoreDataStore
import ContactClient
import ContactClientLive
import Combine
import Foundation
import SharedModels
import CoreData
import HttpRequest

public final class CoreDataClient {

  public var contactClient: ContactClient
  public var contacts = [Contact]()

  public init(contactClient: ContactClient) {
    self.contactClient = contactClient
  }

  public func getContacts() -> AnyPublisher<[Contact], HTTPError> {
    return self.contactClient.buidContacts()
      .removeDuplicates()
      .mapError {
        return  HTTPError.custom("ContactEntity Fetch data error ", $0)
      }
      .flatMap { contacts in
        self.registerContacts(contacts: contacts)
      }
      .eraseToAnyPublisher()
  }

  public func registerContacts(contacts: [Contact]) -> AnyPublisher<[Contact], HTTPError> {
    var results = [Contact]()
    return self.contactClient.getRegisterUsersFromServer(contacts)
      .map { users -> [Contact] in
        _ = users.map { user in
          if var contact = contacts.first(where: { $0.phoneNumber == user.phoneNumber }) {
            contact.id = contact.identifier
            results.append(contact)
          }
        }
        return results
      }
      .mapError { $0 }
      .eraseToAnyPublisher()
  }

  //  public func save() -> AnyPublisher<[Contact], Never> {
  //    return self.contactClient.buidContacts()
  //      .map { [weak self] contacts in
  //        self?.contactsSubject.send(contacts)
  //
  //        _ = contacts.compactMap { contact in
  //          let contactEntity = ContactEntity(context: CoreDataStore.shared!.moc)
  //          contactEntity.id = ""
  //          contactEntity.fullName = contact.fullName ?? ""
  //          contactEntity.avatar = contact.avatar
  //          contactEntity.identifier = contact.identifier
  //          contactEntity.isRegister = contact.isRegister ?? false
  //          contactEntity.userId = contact.userId! // we are sure we have it
  //          contactEntity.phoneNumber = contact.phoneNumber
  //        }
  //
  //        CoreDataStore.shared?.saveContext()
  //
  //        return contacts
  //      }
  //      .receive(on: DispatchQueue.main)
  //      .replaceError(with: [])
  //      .eraseToAnyPublisher()
  //  }

  //  private func registerUsers(contacts: [Contact]) {
  //    self.contactClient.getRegisterUsersFromServer(contacts)
  //      .subscribe(on: DispatchQueue.main)
  //      .receive(on: DispatchQueue.main)
  //      .sink { completion in
  //        switch completion {
  //
  //        case .finished:
  //          print("")
  //        case .failure(let error):
  //          print(error)
  //        }
  //      } receiveValue: { [weak self] users in
  //
  //        print(#line, "users \(users)")
  //
  //        //let fetchRequest: NSFetchRequest<ContactEntity> = ContactEntity.fetchRequest()
  //
  //        var results = [Contact]()
  //
  //        for user in users {
  //          guard let contact = contacts.first(where: { $0.phoneNumber == user.phoneNumber }) else { continue }
  //          results.append(contact)
  //        }
  //        users.forEach { user in
  //          guard let contact = contacts.first(where: { $0.phoneNumber == user.phoneNumber }) else { continue }
  //          results.append(contact)
  //          fetchRequest.predicate = NSPredicate(format: "phoneNumber = %@", "\(user.phoneNumber)")
  //
  //          do {
  //            guard let results = try CoreDataStore.shared?.moc.fetch(fetchRequest), results.count < 0 else { return }
  //
  //            results.forEach { contactEntity in
  //              contactEntity.setValue(true, forKey: "isRegister")
  //              contactEntity.setValue(user.attachments?.last?.imageUrlString, forKey: "avatar")
  //            }
  //
  //          } catch {
  //            print("failed to fetch record from CoreData")
  //          }
  //
  //        }
  //
  //        CoreDataStore.shared?.saveContext()
  //        self?.contacts = results
  //      }.store(in: &cancellables)
  //
  //  }

  //  public func fetchContactEntityThenConvertToContacts() -> AnyPublisher<[Contact], HTTPError> {
  //    let request: NSFetchRequest<ContactEntity> = ContactEntity.fetchRequest()
  //    let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
  //    request.sortDescriptors = [sortDescriptor]
  //
  //    return CoreDataPublisher(
  //      request: request,
  //      context: CoreDataStore.shared!.moc
  //    )
  //    .map { cons in
  //      return cons.compactMap { $0.contact() }
  //        .filter { $0.isRegister == true }
  //        .sorted(by: { $0.fullName ?? "" < $1.fullName ?? "" })
  //    }
  //    .print()
  //    .receive(on: DispatchQueue.main)
  //    .mapError {
  //      return  HTTPError.custom("ContactEntity Fetch data error ", $0)
  //    }
  //    .eraseToAnyPublisher()
  //
  //  }

}
