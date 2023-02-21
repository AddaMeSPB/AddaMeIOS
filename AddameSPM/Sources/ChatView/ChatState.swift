//
//  ChatState.swift
//
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import ComposableArchitecture
import AddaSharedModels
import WebSocketReducer

extension Chat.State {
    public static let placeholderMessages = Self(
        isLoadingPage: true,
        conversation: .lookingForAcompanyDraff,
        messages: .init(uniqueElements: MessagePage.draff.items),
        currentUser: .withFirstName,
        websocketState: .init(user: .withFirstName)
    )

//    (
//    currentUser
//    isLoadingPage: true,
//    messages: .init(uniqueElements: MessagePage.draff.items)
//  )
}
