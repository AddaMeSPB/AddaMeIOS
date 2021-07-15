//
//  ContactRowState.swift
//  
//
//  Created by Saroar Khandoker on 26.06.2021.
//

import Contacts
import ComposableArchitecture
import SharedModels
import HttpRequest
import ChatView

public struct ContactRowState: Equatable, Identifiable {
  public init(
    id: String? = UUID().uuidString,
    isMoving: Bool = false,
    contact: Contact
  ) {
    self.id = id
    self.isMoving = isMoving
    self.contact = contact
  }

  public var id: String?
  public var isMoving: Bool = false
  public var contact: Contact

}
