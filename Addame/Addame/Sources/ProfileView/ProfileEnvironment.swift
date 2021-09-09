//
//  ProfileEnvironment.swift
//
//
//  Created by Saroar Khandoker on 09.04.2021.
//

import AttachmentClient
import AuthClient
import ComposableArchitecture
import EventClient
import SharedModels
import UserClient

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
