//
//  ProfileState.swift
//  
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import SwiftUI
import SharedModels
import KeychainService
import ComposableArchitecture

public struct ProfileState: Equatable {

  public static func == (lhs: ProfileState, rhs: ProfileState) -> Bool {
    return lhs.isUserFristNameUpdated == rhs.isUserFristNameUpdated
  }

  @AppStorage(AppUserDefaults.Key.isUserFristNameUpdated.rawValue)
  public var isUserFristNameUpdated: Bool = false

  public var alert: AlertState<ProfileAction>?
  public var isUploadingImage: Bool = false
  public var showingImagePicker = false
  public var inputImage: UIImage?
  public var moveToSettingsView = false
  public var moveToAuthView: Bool = false
  public var user: User = .draff
  public var isUserHaveAvatarLink: Bool = false
  public var myEvents: IdentifiedArrayOf<EventResponse.Item> = []

  public var isLoadingPage = false
  public var canLoadMorePages = true
  public var currentPage = 1

  public init(
    alert: AlertState<ProfileAction>? = nil,
    isUploadingImage: Bool = false,
    showingImagePicker: Bool = false,
    inputImage: UIImage? = nil,
    moveToSettingsView: Bool = false,
    moveToAuthView: Bool = false,
    user: User = .draff,
    isUserHaveAvatarLink: Bool = false,
    myEvents: IdentifiedArrayOf<EventResponse.Item> = [],
    isLoadingPage: Bool = false,
    canLoadMorePages: Bool = true,
    currentPage: Int = 1
  ) {
    self.alert = alert
    self.isUploadingImage = isUploadingImage
    self.showingImagePicker = showingImagePicker
    self.inputImage = inputImage
    self.moveToSettingsView = moveToSettingsView
    self.moveToAuthView = moveToAuthView
    self.user = user
    self.isUserHaveAvatarLink = isUserHaveAvatarLink
    self.myEvents = myEvents
    self.isLoadingPage = isLoadingPage
    self.canLoadMorePages = canLoadMorePages
    self.currentPage = currentPage
  }

}

public extension ProfileState {
  var view: ProfileView.ViewState {
    ProfileView.ViewState(
      alert: self.alert,
      isUploadingImage: self.isUploadingImage,
      showingImagePicker: self.showingImagePicker,
      inputImage: self.inputImage,
      moveToSettingsView: self.moveToSettingsView,
      moveToAuthView: self.moveToAuthView,
      user: self.user,
      isUserHaveAvatarLink: self.isUserHaveAvatarLink,
      isLoadingPage: self.isLoadingPage,
      canLoadMorePages: self.canLoadMorePages,
      currentPage: self.currentPage
    )
  }
}

// swiftlint:disable all
extension ProfileState {

  private static var user = User(
    id: "5fabb05d2470c17919b3c0e2", phoneNumber: "+79218888888", avatarUrl: nil,
    firstName: "Alex", lastName: "Khan", email: nil, contactIDs: nil, deviceIDs: nil,
    attachments: [
      Attachment(id: "5fb6736c1432f950f8ea2d33", type: .image, userId: "5fabb05d2470c17919b3c0e2", imageUrlString: "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/5fabb05d2470c17919b3c0e2_1605792619988.jpeg", audioUrlString: nil, videoUrlString: nil, fileUrlString: nil, createdAt: nil, updatedAt: nil),
      Attachment(id: "5fb681d6fb999dc956323a05", type: .image, userId: "5fabb05d2470c17919b3c0e2", imageUrlString: "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/1605796266916.jpeg", audioUrlString: nil, videoUrlString: nil, fileUrlString: nil, createdAt: nil, updatedAt: nil),
      Attachment(id: "5fb6bba4d62847cc58a5218a", type: .image, userId: "5fabb05d2470c17919b3c0e2", imageUrlString: "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/1605811106589.jpeg", audioUrlString: nil, videoUrlString: nil, fileUrlString: nil, createdAt: nil, updatedAt: nil),
      Attachment(id: "5fb6bc48d63734254b0eb777", type: .image, userId: "5fabb05d2470c17919b3c0e2", imageUrlString: "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/1605811270871.jpeg", audioUrlString: nil, videoUrlString: nil, fileUrlString: nil, createdAt: nil, updatedAt: nil),
      Attachment(id: "5fb7b5e0d54eaebe3d264ace", type: .image, userId: "5fabb05d2470c17919b3c0e2", imageUrlString: "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/1605875164101.heic", audioUrlString: nil, videoUrlString: nil, fileUrlString: nil, createdAt: nil, updatedAt: nil),
      Attachment(id: "5fce0931ed6264cb3536a7cb", type: .image, userId: "5fabb05d2470c17919b3c0e2", imageUrlString: "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/1607338279849.heic", audioUrlString: nil, videoUrlString: nil, fileUrlString: nil, createdAt: nil, updatedAt: nil),
      Attachment(id: "5fce094221b4a84f64924bf3", type: .image, userId: "5fabb05d2470c17919b3c0e2", imageUrlString: "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/1607338304864.heic", audioUrlString: nil, videoUrlString: nil, fileUrlString: nil, createdAt: nil, updatedAt: nil)
    ],
    createdAt: Date(), updatedAt: Date()
  )

  public static let events = Self(
    user: user,
    myEvents: [
      .init(id: "5fbfe53675a93bda87c7cb16", name: "Cool :)", categories: "General", duration: 14400, isActive: true, conversationsId: "5fbfe5361cdd72e23297914a", addressName: "8к1литД улица Вавиловых , Saint Petersburg", type: "Point", sponsored: false, overlay: false, coordinates: [60.020532228306031, 30.388014239849944], createdAt: Date(), updatedAt: Date() ),
      .init(id: "5fbe8a8c8ba94be8a688324a", name: "Awesome 🤩 app", categories: "General", duration: 14400, isActive: true, conversationsId: "5fbe8a8c492346f651b57946", addressName: "8к1литД улица Вавиловых , Saint Petersburg", type: "Point", sponsored: false, overlay: false, coordinates: [60.020525506753494, 30.387988546891499], createdAt: Date(), updatedAt: Date()),
      .init(id: "5fbea245b226053f0ece711c", name: "Bicycling 🚴🏽", categories: "LookingForAcompany", duration: 14400, isActive: true, conversationsId: "5fbe8a8c492346f651b57946", addressName: "9к5 улица Бутлерова Saint Petersburg, Saint Petersburg", type: "Point", sponsored: false, overlay: false, coordinates: [60.00380571585201, 30.399472870547118], createdAt: Date(), updatedAt: Date()),
      .init(id: "5fbea245b226053f0ece711c", name: "Walk Around 🚶🏽🚶🏼‍♀️", categories: "LookingForAcompany", imageUrl: "https://avatars.mds.yandex.net/get-pdb/2776508/af73774d-7409-4e73-81c8-c8ab127c2f8b/s1200?webp=false", duration: 14400, isActive: true, conversationsId: "5fbe8a8c492346f651b57946", addressName: "188839, Первомайское, СНТ Славино-2 Поселок, 31 Первомайское Россия", type: "Point", sponsored: false, overlay: false, coordinates: [60.261340452875721, 29.873706166262373], createdAt: Date(), updatedAt: Date())
    ]
  )
}
