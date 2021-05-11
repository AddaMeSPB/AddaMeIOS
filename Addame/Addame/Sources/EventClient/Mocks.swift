//
//  EventClient.swift
//  
//
//  Created by Saroar Khandoker on 25.01.2021.
//

import Combine
import Foundation
import HttpRequest
import SharedModels

extension EventClient {
  public static let empty = Self(
    events: { _, _  in
      Just(EventResponse.emptry)
      .setFailureType(to: HTTPError.self)
      .eraseToAnyPublisher()
    }, create: { _,_   in
      Just(Event.draff)
      .setFailureType(to: HTTPError.self)
      .eraseToAnyPublisher()
    }
  )
  
  public static let happyPath = Self(
    events: { _,_   in
      Just(
        EventResponse(
          items: [
            .init(id: "5fbfe53675a93bda87c7cb16", name: "Cool :)", categories: "General", duration: 14400, isActive: true, conversationsId: "5fbfe5361cdd72e23297914a", addressName: "8к1литД улица Вавиловых , Saint Petersburg", type: "Point", sponsored: false, overlay: false, coordinates: [60.020532228306031, 30.388014239849944], createdAt: Date(), updatedAt: Date() ),
            .init(id: "5fbe8a8c8ba94be8a688324a", name: "Awesome 🤩 app", categories: "General", duration: 14400, isActive: true, conversationsId: "5fbe8a8c492346f651b57946", addressName: "8к1литД улица Вавиловых , Saint Petersburg", type: "Point", sponsored: false, overlay: false, coordinates: [60.020525506753494, 30.387988546891499], createdAt: Date(), updatedAt: Date()),
            .init(id: "5fbea245b226053f0ece711c", name: "Bicycling 🚴🏽", categories: "LookingForAcompany", duration: 14400, isActive: true, conversationsId: "5fbe8a8c492346f651b57946", addressName: "9к5 улица Бутлерова Saint Petersburg, Saint Petersburg", type: "Point", sponsored: false, overlay: false, coordinates: [60.00380571585201, 30.399472870547118], createdAt: Date(), updatedAt: Date()),
            .init(id: "5fbea245b226053f0ece711c", name: "Walk Around 🚶🏽🚶🏼‍♀️", categories: "LookingForAcompany", imageUrl: "https://avatars.mds.yandex.net/get-pdb/2776508/af73774d-7409-4e73-81c8-c8ab127c2f8b/s1200?webp=false", duration: 14400, isActive: true, conversationsId: "5fbe8a8c492346f651b57946", addressName: "188839, Первомайское, СНТ Славино-2 Поселок, 31 Первомайское Россия", type: "Point", sponsored: false, overlay: false, coordinates: [60.261340452875721, 29.873706166262373], createdAt: Date(), updatedAt: Date())
          ],
          metadata: .init(per: 10, total: 10, page: 1)
        )
      )
      .setFailureType(to: HTTPError.self)
      .eraseToAnyPublisher()
    }, create: { _,_  in
      Just(
        Event(id: "5fb1510012de9980bd0c2efc", name: "Testing data", details: "Waitting for details", imageUrl: "https://avatars.mds.yandex.net/get-pdb/2776508/af73774d-7409-4e73-81c8-c8ab127c2f8b/s1200?webp=false", duration: 14400, categories: "General", isActive: true, addressName: "8к1литД улица Вавиловых , Saint Petersburg", type: .Point, sponsored: false, overlay: false, coordinates: [60.020532228306031, 30.388014239849944])
      )
      .setFailureType(to: HTTPError.self)
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
    }

  )
  
}
