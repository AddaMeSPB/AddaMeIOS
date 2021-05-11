import CoreDataStore
import ContactClient
import ContactClientLive
import Combine
import Foundation
import SharedModels
import CoreData

public final class CoreDataClient {
  
  public var contactClient: ContactClient
  
  private var cancellables = Set<AnyCancellable>()
  private var contactsSubject = PassthroughSubject<[Contact], Never>()
  
  var contactsPublisher: AnyPublisher<[Contact], Never> {
    contactsSubject.eraseToAnyPublisher()
  }
  
  public init(contactClient: ContactClient) {
    self.contactClient = contactClient
    
    self.contactsPublisher.sink { [weak self] contacts in
      self?.registerUsers(contacts: contacts)
    }.store(in: &cancellables)
  }
  
  public func saveContactEntitiesToCoreData()  {
    self.contactClient.buidContacts()
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
          print("")
        case .failure(let error):
          print(error.localizedDescription)
        }
      }, receiveValue: { [weak self] contacts in
        self?.contactsSubject.send(contacts)
        
        contacts.forEach { contact in
          let contactEntity = ContactEntity(context: CoreDataStore.shared!.moc)
          contactEntity.id = ""
          contactEntity.fullName = contact.fullName ?? ""
          contactEntity.avatar = contact.avatar
          contactEntity.identifier = contact.identifier
          contactEntity.isRegister = contact.isRegister ?? false
          contactEntity.userId = contact.userId! // we are sure we have it
          contactEntity.phoneNumber = contact.phoneNumber
        }
        
      })
      .store(in: &cancellables)
    
  }
  
  private func registerUsers(contacts: [Contact]) {
    self.contactClient.getRegisterUsersFromServer(contacts)
      .receive(on: DispatchQueue.main)
      .sink { completion in
        switch completion {
        
        case .finished:
          print("")
        case .failure(let error):
          print(error)
        }
      } receiveValue: { users in
        
        let fetchRequest: NSFetchRequest<ContactEntity> = ContactEntity.fetchRequest()
       
        users.forEach { user in
          
          fetchRequest.predicate = NSPredicate(format: "phoneNumber = %@", "\(user.phoneNumber)")
          
          do {
            guard let results = try  CoreDataStore.shared?.moc.fetch(fetchRequest) else {return }
            
            results.forEach { contactEntity in
              contactEntity.setValue(true, forKey: "isRegister")
              contactEntity.setValue(user.attachments?.last?.imageUrlString, forKey: "avatar")
            }
            
          } catch {
            print("failed to fetch record from CoreData")
          }
          
        }
        
        CoreDataStore.shared?.saveContext()
        
      }.store(in: &cancellables)
    
  }
  

}


