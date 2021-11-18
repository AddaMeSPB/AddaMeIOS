//
//  ContactRowAction.swift
//
//
//  Created by Saroar Khandoker on 25.06.2021.
//

import ChatView
import Contacts
import HTTPRequestKit
import SharedModels

public enum ContactRowAction: Equatable {
  case moveToChatRoom(Bool)
  case chatWith(name: String, phoneNumber: String)
}
