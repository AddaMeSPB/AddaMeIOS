//
//  ProfileState.swift
//
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import ComposableArchitecture
import SettingsView
import AddaSharedModels
import SwiftUI
import ImagePicker
import MyEventsView


// swiftlint:disable all
extension Profile.State {
//  private static var userWithoutAvatar = User(
//    id: "5fabb05d2470c17919b3c0e3",
//    phoneNumber: "+79218888889",
//    avatarUrl: nil,
//    firstName: "Secrect",
//    lastName: "Super",
//    email: nil, contactIDs: nil, deviceIDs: nil,
//    attachments: nil,
//    createdAt: Date(), updatedAt: Date()
//  )
//
//  private static var userWithAvatar = User(
//    id: "5fabb05d2470c17919b3c0e2", phoneNumber: "+79218888888", avatarUrl: nil,
//    firstName: "Alex", lastName: "Khan", email: nil, contactIDs: nil, deviceIDs: nil,
//    attachments: [
//      Attachment(
//        id: "5fb6736c1432f950f8ea2d33", type: .image, userId: "5fabb05d2470c17919b3c0e2",
//        imageUrlString:
//          "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/5fabb05d2470c17919b3c0e2_1605792619988.jpeg",
//        audioUrlString: nil, videoUrlString: nil, fileUrlString: nil, createdAt: nil, updatedAt: nil
//      ),
//      Attachment(
//        id: "5fb681d6fb999dc956323a05", type: .image, userId: "5fabb05d2470c17919b3c0e2",
//        imageUrlString:
//          "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/1605796266916.jpeg",
//        audioUrlString: nil, videoUrlString: nil, fileUrlString: nil, createdAt: nil, updatedAt: nil
//      ),
//      Attachment(
//        id: "5fb6bba4d62847cc58a5218a", type: .image, userId: "5fabb05d2470c17919b3c0e2",
//        imageUrlString:
//          "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/1605811106589.jpeg",
//        audioUrlString: nil, videoUrlString: nil, fileUrlString: nil, createdAt: nil, updatedAt: nil
//      ),
//      Attachment(
//        id: "5fb6bc48d63734254b0eb777", type: .image, userId: "5fabb05d2470c17919b3c0e2",
//        imageUrlString:
//          "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/1605811270871.jpeg",
//        audioUrlString: nil, videoUrlString: nil, fileUrlString: nil, createdAt: nil, updatedAt: nil
//      ),
//      Attachment(
//        id: "5fb7b5e0d54eaebe3d264ace", type: .image, userId: "5fabb05d2470c17919b3c0e2",
//        imageUrlString:
//          "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/1605875164101.heic",
//        audioUrlString: nil, videoUrlString: nil, fileUrlString: nil, createdAt: nil, updatedAt: nil
//      ),
//      Attachment(
//        id: "5fce0931ed6264cb3536a7cb", type: .image, userId: "5fabb05d2470c17919b3c0e2",
//        imageUrlString:
//          "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/1607338279849.heic",
//        audioUrlString: nil, videoUrlString: nil, fileUrlString: nil, createdAt: nil, updatedAt: nil
//      ),
//      Attachment(
//        id: "5fce094221b4a84f64924bf3", type: .image, userId: "5fabb05d2470c17919b3c0e2",
//        imageUrlString:
//          "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/1607338304864.heic",
//        audioUrlString: nil, videoUrlString: nil, fileUrlString: nil, createdAt: nil, updatedAt: nil
//      ),
//    ],
//    createdAt: Date(), updatedAt: Date()
//  )
//
//  private static var events: IdentifiedArrayOf<EventResponse> = [
//    .init(
//      id: "5fbfe53675a93bda87c7cb16", name: "In Future people will be very kind and happy!", categories: "General", duration: 14400,
//      isActive: true, conversationsId: "5fbfe5361cdd72e23297914a",
//      addressName: "8к1литД улица Вавиловых , Saint Petersburg", type: "Point", sponsored: false,
//      overlay: false, coordinates: [60.020532228306031, 30.388014239849944], createdAt: Date(),
//      updatedAt: Date()),
//    .init(
//      id: "5fbe8a8c8ba94be8a688324a", name: "Awesome 🤩 app", categories: "General",
//      duration: 14400, isActive: true, conversationsId: "5fbe8a8c492346f651b57946",
//      addressName: "8к1литД улица Вавиловых , Saint Petersburg", type: "Point", sponsored: false,
//      overlay: false, coordinates: [60.020525506753494, 30.387988546891499], createdAt: Date(),
//      updatedAt: Date()),
//    .init(
//      id: "5fbea245b226053f0ece711c", name: "Bicycling 🚴🏽", categories: "LookingForAcompany",
//      duration: 14400, isActive: true, conversationsId: "5fbe8a8c492346f651b57946",
//      addressName: "9к5 улица Бутлерова Saint Petersburg, Saint Petersburg", type: "Point",
//      sponsored: false, overlay: false, coordinates: [60.00380571585201, 30.399472870547118],
//      createdAt: Date(), updatedAt: Date()),
//    .init(
//      id: "5fbea245b226053f0ece712c", name: "Walk Around 🚶🏽🚶🏼‍♀️", categories: "LookingForAcompany",
//      imageUrl:
//        "https://avatars.mds.yandex.net/get-pdb/2776508/af73774d-7409-4e73-81c8-c8ab127c2f8b/s1200?webp=false",
//      duration: 14400, isActive: true, conversationsId: "5fbe8a8c492346f651b57946",
//      addressName: "188839, Первомайское, СНТ Славино-2 Поселок, 31 Первомайское Россия",
//      type: "Point", sponsored: false, overlay: false,
//      coordinates: [60.261340452875721, 29.873706166262373], createdAt: Date(), updatedAt: Date()),
//  ]
//
//  public static let profileStateWithUserWithAvatar = Self(
//    alert: nil,
//    user: userWithAvatar,
//    imageURLs: [
//      "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/1607338279849.heic",
//      "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/1607338304864.heic",
//      "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/1605875164101.heic",
//      "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/1605811106589.jpeg",
//      "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/1605796266916.jpeg",
//      "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/5fabb05d2470c17919b3c0e2_1605792619988.jpeg"
//    ]
//  )
//
//  public static let profileStateWithUserWithoutAvatar = Self(
//    alert: nil,
//    user: userWithoutAvatar
//  )
 }
