//
//  ProfileEnvironment.swift
//  
//
//  Created by Saroar Khandoker on 09.04.2021.
//

import UserClient
import EventClient
import AuthClient
import AttachmentClient
import ComposableArchitecture
import AddaMeModels


public struct ProfileEnvironment {
  
  public var userClient: UserClient
  public var eventClient: EventClient
  public var authClient: AuthClient
  public var attachmentClient: AttachmentClient
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  
  public init(
    userClient: UserClient,
    eventClient: EventClient,
    authClient: AuthClient,
    attachmentClient: AttachmentClient,
    mainQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.userClient = userClient
    self.eventClient = eventClient
    self.authClient = authClient
    self.attachmentClient = attachmentClient
    self.mainQueue = mainQueue
  }
  
}
