//
//  ProfileEnvironment.swift
//
//
//  Created by Saroar Khandoker on 09.04.2021.
//

import AttachmentClient
import AttachmentClientLive
import AuthClient
import AuthClientLive
import ComposableArchitecture
import EventClient
import EventClientLive
import SharedModels
import UserClient
import UserClientLive
import UIKit
import KeychainService
import Combine
import HTTPRequestKit

public struct ProfileEnvironment {
  public var userClient: UserClient
  public var eventClient: EventClient
  public var authClient: AuthClient
  public var attachmentClient: AttachmentClient
  public var backgroundQueue: AnySchedulerOf<DispatchQueue>
  public var mainQueue: AnySchedulerOf<DispatchQueue>

  public init(
    userClient: UserClient,
    eventClient: EventClient,
    authClient: AuthClient,
    attachmentClient: AttachmentClient,
    backgroundQueue: AnySchedulerOf<DispatchQueue>,
    mainQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.userClient = userClient
    self.eventClient = eventClient
    self.authClient = authClient
    self.attachmentClient = attachmentClient
    self.backgroundQueue = backgroundQueue
    self.mainQueue = mainQueue
  }
}

extension ProfileEnvironment {
  public static let live: ProfileEnvironment = .init(
    userClient: UserClient.live(api: .build),
    eventClient: EventClient.live(api: .build),
    authClient: AuthClient.live(api: .build),
    attachmentClient: AttachmentClient.live(api: .build),
    backgroundQueue: .main,
    mainQueue: .main
  )

  public static let happyPath: ProfileEnvironment = .init(
    userClient: .happyPath,
    eventClient: .happyPath,
    authClient: .happyPath,
    attachmentClient: .happyPath,
    backgroundQueue: .immediate,
    mainQueue: .immediate
  )

}
