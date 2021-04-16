//
//  ContactRow.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 04.12.2020.
//

import SwiftUI
import CoreDataStore
import AddaMeModels
import AsyncImageLoder

public struct ContactRow: View {
  var contact: Contact

  @Environment(\.colorScheme) var colorScheme
  
  public init(contact: Contact) {
    self.contact = contact
  }
  
  public var body: some View {
    HStack {
      if contact.avatar == nil {
        Image(systemName: "person.crop.circle.fill")
          .resizable()
          .frame(width: 55, height: 55)
          .clipShape(Circle())
          .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
      } else {
        AsyncImage(
          urlString: contact.avatar,
          placeholder: { Text("Loading...").frame(width: 35, height: 35, alignment: .center) },
          image: {
            Image(uiImage: $0).resizable()
          }
        )
        .aspectRatio(contentMode: .fill)
        .frame(width: 45, height: 45, alignment: .center)
        .clipShape(Circle())
        
      }
      
      
      VStack(alignment: .leading) {
        Text(contact.fullName ?? "unknown")
        Text(contact.phoneNumber)
      }
      
      Spacer(minLength: 0)
      
//      Button(action: {
//        startChat(contact)
//      }, label: {
//        Image(systemName: "bubble.left.and.bubble.right.fill")
//          .imageScale(.large)
//          .frame(width: 60, height: 60, alignment: .center)
//      })
//      .sheet(isPresented: $conversationView.startChat) {
//        LazyView(
//          ChatRoomView(conversation: conversationView.conversation, isFromContactView: true)
//            .edgesIgnoringSafeArea(.bottom)
//        )
//      }
      
    }
  }
  
//  func startChat(_ contact: ContactEntity) {
//    guard let currentUSER: CurrentUser = KeychainService.loadCodable(for: .currentUser) else {
//      return
//    }
//
//    let conversation = CreateConversation(
//      title: "\(currentUSER.fullName), \(contact.fullName)",
//      type: .oneToOne,
//      opponentPhoneNumber: contact.phoneNumber
//    )
//
//    conversationView.startOneToOneChat(conversation)
//  }
  
  func invite() {
    let url = URL(string: "https://testflight.apple.com/join/gXWnCqLB")
    let av = UIActivityViewController(activityItems: [url!], applicationActivities: nil)
    UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
  }
}

//struct ContactRow_Previews: PreviewProvider {
//  static var previews: some View {
//    ContactRow(contact: <#ContactEntity#>)
//  }
//}
