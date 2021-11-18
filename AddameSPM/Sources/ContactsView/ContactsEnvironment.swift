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

public struct ContactsEnvironment {
  public let coreDataClient: CoreDataClient
  public var backgroundQueue: AnySchedulerOf<DispatchQueue>
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  private var cancellables = Set<AnyCancellable>()

  public init(
    coreDataClient: CoreDataClient,
    backgroundQueue: AnySchedulerOf<DispatchQueue>,
    mainQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.backgroundQueue = backgroundQueue
    self.coreDataClient = coreDataClient
    self.mainQueue = mainQueue
  }
}

extension ContactsEnvironment {
  public static let live: ContactsEnvironment = .init(
    coreDataClient: CoreDataClient(
      contactClient: ContactClient.live(api: .build)
    ),
    backgroundQueue: .main,
    mainQueue: .main
  )
}
