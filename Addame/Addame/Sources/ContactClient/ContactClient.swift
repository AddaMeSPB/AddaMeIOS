import Contacts
import SwiftUI
import Combine
import CoreData
import HttpRequest
import SharedModels
import PhoneNumberKit
import CombineContacts

public struct ContactClient {

  public typealias AuthorizationStatusHandler = () -> AnyPublisher<CNAuthorizationStatus, Never>
  public typealias BuildContactsHandler = () -> AnyPublisher<[Contact], ContactError>
  public typealias GetRegisterUsersHandler = ([Contact]) -> AnyPublisher<[User], HTTPError>
  
  public var authorization: AuthorizationStatusHandler
  public var buidContacts: BuildContactsHandler
  public var getRegisterUsersFromServer: GetRegisterUsersHandler
  
  public init(
    authorization: @escaping AuthorizationStatusHandler,
    buidContacts: @escaping BuildContactsHandler,
    getRegisterUsersFromServer: @escaping GetRegisterUsersHandler
  ) {
    self.authorization = authorization
    self.buidContacts = buidContacts
    self.getRegisterUsersFromServer = getRegisterUsersFromServer
  }
  
}

//import Combine
//import Contacts
//
//class Contact: ObservableObject {
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
//}
//
//struct ContactView: View {
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
//}

