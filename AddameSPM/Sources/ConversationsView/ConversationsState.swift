import ChatView
import ComposableArchitecture
import ContactsView
import Foundation
import AddaSharedModels

extension Conversations.State {
    public static let placholderConversations = Self(
        isLoadingPage: true,
        conversations: .init(uniqueElements: ConversationOutPut.conversationsMock),
        chatState: .init(
            conversation: .exploreAreaDraff, currentUser: .withFirstName,
            websocketState: .init(user: .withFirstName)
        ),
        websocketState: .init(user: .withFirstName)
    )
}
