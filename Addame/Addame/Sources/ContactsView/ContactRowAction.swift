//
//  ContactRowAction.swift
//  
//
//  Created by Saroar Khandoker on 25.06.2021.
//

import SharedModels
import HttpRequest
import ChatView
import Contacts

public enum ContactRowAction: Equatable {
  case moveToChatRoom(Bool)
  case chatWith(name: String, phoneNumber: String)
}
