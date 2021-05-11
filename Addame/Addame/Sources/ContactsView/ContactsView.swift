import SwiftUI
import Contacts
import Foundation
import CoreDataStore
import SharedModels

import Combine
import ContactClient
import ContactClientLive
import CombineContacts
import CoreData
import CoreDataClient

class ContactViewModel: ObservableObject {
  
  @Published var contacts: [Contact] = []
  private var cancellables = Set<AnyCancellable>()
  let fetchRequest: NSFetchRequest<ContactEntity> = ContactEntity.fetchRequest()
  
  @Published var invalidPermission = false
  
  var coreDataClient: CoreDataClient
  
  public init() {
    coreDataClient = CoreDataClient(contactClient: .live(api: .build))
  }
  
  public func loadData() {
    coreDataClient.contactClient.authorization()
      .receive(on: DispatchQueue.main)
      .map { $0 == .denied || $0 == .restricted }
      .assign(to: \.invalidPermission, on: self)
      .store(in: &cancellables)
    
    coreDataClient.contactClient.authorization()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] (status) in
        if status == .authorized {
          self?.coreDataClient.saveContactEntitiesToCoreData()
        }
      }
      .store(in: &cancellables)
    

    CoreDataPublisher(
      request: ContactEntity.fetchRequest(),
      context: CoreDataStore.shared!.moc
    )
    .map { contactEntities in
      contactEntities.map {
        Contact(id: $0.id, identifier: $0.identifier, userId: $0.userId, phoneNumber: $0.phoneNumber, fullName: $0.fullName, avatar: $0.avatar, isRegister: $0.isRegister)
      }
      .filter { $0.isRegister == true }
      .sorted(by: { $0.fullName ?? "" < $1.fullName ?? "" })
    }

    .receive(on: DispatchQueue.main)
    .sink { completion in
      switch completion {

      case .finished:
        print(#line, "finished")
      case .failure(let error):
        print(#line, "fetch contactEntities from coreData: \(error)")
      }
    } receiveValue: { [weak self] newContacts in
      print(#line, "\(newContacts.count)")
      let registerContacts = newContacts
      self?.contacts = registerContacts
    }
    .store(in: &cancellables)
  }
}

public struct ContactsView: View {
  @ObservedObject var contactViewModel: ContactViewModel
  
  public init() {
    contactViewModel = ContactViewModel()
  }
  
  public var body: some View {
    List {
      ForEach(contactViewModel.contacts, id: \.identifier) { contact in
        ContactRow(contact: contact)
      }
    }
    .onAppear {
      contactViewModel.loadData()
    }
    .alert(isPresented: self.$contactViewModel.invalidPermission) {
      Alert(
        title: Text("TITLE"),
        message: Text("Please go to Settings and turn on the permissions"),
        primaryButton: .cancel(Text("Cancel")),
        secondaryButton: .default(Text("Settings"), action: {
          if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
          }
        }))
    }
    .navigationBarTitle("Contacts", displayMode: .automatic)
  }
  
}

struct ContactsView_Previews: PreviewProvider {
  static var previews: some View {
    ContactsView()
  }
}
