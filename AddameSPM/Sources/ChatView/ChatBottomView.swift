//
//  ChatBottomView.swift
//
//
//  Created by Saroar Khandoker on 18.06.2021.
//

import ComposableArchitecture
import AddaSharedModels
import SwiftUI
import SwiftUIExtension
import SwiftUIHelpers
import FoundationExtension

public struct ChatBottom: Reducer {
    public struct State: Equatable {
        public init(
            composedMessage: String = String.empty,
            isMicButtonHide: Bool = false,
            preWordCount: Int = 0,
            newLineCount: Int = 1,
            placeholderString: String = "Type...",
            tEheight: CGFloat = 40,
            messageToSend: String = ""
        ) {
            self.composedMessage = composedMessage
            self.isMicButtonHide = isMicButtonHide
            self.preWordCount = preWordCount
            self.newLineCount = newLineCount
            self.placeholderString = placeholderString
            self.tEheight = tEheight
            self.messageToSend = messageToSend
        }

        public var composedMessage = String.empty
        public var isMicButtonHide = false
        public var preWordCount: Int = 0
        public var newLineCount = 1
        public var placeholderString: String = "Type..."
        public var tEheight: CGFloat = 40
        public var messageToSend: String = ""
    }

    public enum Action: Equatable {
        case sendButtonTapped
        case messageToSendChanged(String)
    }

    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce(self.core)
    }

    func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {

        case let .messageToSendChanged(message):
          state.messageToSend = message

          return .none

        case .sendButtonTapped:
            return .none
        }
    }
}

extension ChatBottomView {
    public struct ViewState: Equatable {
        public init(state: ChatBottom.State) {
            self.composedMessage = state.composedMessage
            self.isMicButtonHide = state.isMicButtonHide
            self.preWordCount = state.preWordCount
            self.newLineCount = state.newLineCount
            self.placeholderString = state.placeholderString
            self.tEheight = state.tEheight
            self.messageToSend = state.messageToSend
        }

        public var composedMessage = String.empty
        public var isMicButtonHide = false
        public var preWordCount: Int = 0
        public var newLineCount = 1
        public var placeholderString: String = "Type..."
        public var tEheight: CGFloat = 40
        public var messageToSend: String = ""
    }

    public enum ViewAction: Equatable {
        case sendButtonTapped
        case messageToSendChanged(String)
    }
}

extension ChatBottom.Action {
  init(_ action: ChatBottomView.ViewAction) {
    switch action {
    case .sendButtonTapped:
        self = .sendButtonTapped
    case .messageToSendChanged(let string):
        self = .messageToSendChanged(string)
    }
  }
}

//HidableTabView(
//    isHidden: viewStore.binding(
//        get: \.isHidden,
//        send: ViewAction.tabViewIsHidden
//    ),
//    selection: viewStore.binding(
//        get: \.selectedTab,
//        send: ViewAction.didSelectTab
//    )
//)

struct ChatBottomView: View {

    @Environment(\.colorScheme) var colorScheme
    public let store: StoreOf<ChatBottom>

    public init(store: StoreOf<ChatBottom>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(self.store, observe: ViewState.init, send: ChatBottom.Action.init) { viewStore in
            ZStack {
                VStack {
                    HStack {
                        TextViewFromUIKit(
                            text: viewStore.binding(
                                get: \.messageToSend,
                                send: ViewAction.messageToSendChanged
                            )
                            .removeDuplicates()
                        )
                        .lineLimit(9)
                        .padding([.top,.leading], 5)
                        .padding(.bottom, -5)
                        .accentColor(Color.green)
                        .overlay(
                          RoundedRectangle(cornerRadius: 10)
                            .stroke(viewStore.messageToSend.isEmpty ? Color.gray : Color.blue, lineWidth: 1)
                        )
                        .padding(.vertical, 10)

                        Button {
                            viewStore.send(.sendButtonTapped)
                        } label: {
                            Image(systemName: "arrow.up")
                                .imageScale(.large)
                                .frame(width: 23, height: 23)
                                .padding(11)
                                .foregroundColor(.white)
                                .background(viewStore.messageToSend.isEmpty ? Color.gray : Color.blue)
                                .clipShape(Circle())
                        }
                        .disabled(viewStore.messageToSend.isEmpty)
                        .foregroundColor(.gray)
                    }
                    .frame(height: 55)
                    .padding(.horizontal, 15)
                    .background(Color.clear)
                    //        .modifier(AdaptsToSoftwareKeyboard())
                }
            }
        }
    }
}

//struct ChatBottomView_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack {
//            Spacer()
//            ChatBottomView(
//                store: .init(
//                    initialState: ChatBottom.State(),
//                    reducer: ChatBottom()
//                )
//            )
//        }
//    }
//}
