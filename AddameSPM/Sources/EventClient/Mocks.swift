//
//  EventClient.swift
//
//
//  Created by Saroar Khandoker on 25.01.2021.
//

import Combine
import Foundation
import HTTPRequestKit
import SharedModels

// swiftlint:disable all
extension EventClient {
  private static let data = Date(timeIntervalSince1970: 0)
  public static let empty = Self(
    events: { _, _ in
      Just(EventResponse.emptry)
        .setFailureType(to: HTTPRequest.HRError.self)
        .eraseToAnyPublisher()
    },
    create: { _, _ in
      Just(EventResponse.Item.draff)
        .setFailureType(to: HTTPRequest.HRError.self)
        .eraseToAnyPublisher()
    }
  )

  public static let happyPath = Self(
    events: { _, _ in
      Just(
        EventResponse(
          items: [
            .init(
              id: "5fbfe53675a93bda87c7cb10", name: "In Future people will be very kind and happy!", categories: "General",
              duration: 14400, isActive: true, conversationsId: "5fbfe5361cdd72e23297914a",
              addressName: "8к1литД улица Вавиловых , Saint Petersburg", type: "Point",
              sponsored: false, overlay: false,
              coordinates: [60.020532228306031, 30.388014239849944], createdAt: data,
              updatedAt: data),
            .init(
              id: "5fbe8a8c8ba94be8a688324c", name: "Awesome 🤩 app ", categories: "General",
              duration: 14400, isActive: true, conversationsId: "5fbe8a8c492346f651b57946",
              addressName: "8к1литД улица Вавиловых , Saint Petersburg", type: "Point",
              sponsored: false, overlay: false,
              coordinates: [60.020525506753494, 30.387988546891499], createdAt: data,
              updatedAt: data),
            .init(
              id: "5fbea245b226053f0ece711c", name: "Bicycling 🚴🏽", categories: "LookingForAcompany",
              duration: 14400, isActive: true, conversationsId: "5fbe8a8c492346f651b57946",
              addressName: "9к5 улица Бутлерова Saint Petersburg, Saint Petersburg", type: "Point",
              sponsored: false, overlay: false,
              coordinates: [60.00380571585201, 30.399472870547118], createdAt: data,
              updatedAt: data),
            .init(
              id: "5fbea245b226053f0ece712c", name: "Walk Around 🚶🏽🚶🏼‍♀️",
              categories: "LookingForAcompany",
              imageUrl:
                "https://avatars.mds.yandex.net/get-pdb/2776508/af73774d-7409-4e73-81c8-c8ab127c2f8b/s1200?webp=false",
              duration: 14400, isActive: true, conversationsId: "5fbe8a8c492346f651b57946",
              addressName: "188839, Первомайское, СНТ Славино-2 Поселок, 31 Первомайское Россия",
              type: "Point", sponsored: false, overlay: false,
              coordinates: [60.261340452875721, 29.873706166262373], createdAt: data,
              updatedAt: data),
          ],
          metadata: .init(per: 2, total: 4, page: 1)
        )
      )
      .setFailureType(to: HTTPRequest.HRError.self)
      .eraseToAnyPublisher()
    },
    create: { _, _ in
      Just(
        EventResponse.Item(
          id: "5fbfe53675a93bda87c7cb16", name: "Create Event For Test", categories: "General",
          imageUrl: "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/1605811270871.jpeg",
          duration: 14400, isActive: true, conversationsId: "5fbfe5361cdd72e23297914a",
          addressName: "8к1литД улица Вавиловых , Saint Petersburg", type: "Point",
          sponsored: false, overlay: false,
          coordinates: [60.020532228306031, 30.388014239849944],
          createdAt: data,
          updatedAt: data
        )
      )
      .setFailureType(to: HTTPRequest.HRError.self)
      .eraseToAnyPublisher()
    }
  )
}
