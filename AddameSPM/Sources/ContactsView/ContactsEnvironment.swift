//
//  ContactsEnvironment.swift
//
//
//  Created by Saroar Khandoker on 13.05.2021.
//

import Combine
import ComposableArchitecture
import CoreDataClient
import CoreDataStore
import ContactClient
import ContactClientLive
import Foundation

public struct ContactsEnvironment {
  public let coreDataClient: CoreDataClient
  public var backgroundQueue: AnySchedulerOf<DispatchQueue>
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var contactClient: ContactClient
  private var cancellables = Set<AnyCancellable>()

  public init(
    coreDataClient: CoreDataClient,
    contactClient: ContactClient,
    backgroundQueue: AnySchedulerOf<DispatchQueue>,
    mainQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.backgroundQueue = backgroundQueue
    self.coreDataClient = coreDataClient
    self.contactClient = contactClient
    self.mainQueue = mainQueue
  }
}

extension ContactsEnvironment {
  public static let live: ContactsEnvironment = .init(
    coreDataClient: CoreDataClient(
      contactClient: ContactClient.live(api: .build)
    ),
    contactClient: .live(api: .build),
    backgroundQueue: .main,
    mainQueue: .main
  )
}
