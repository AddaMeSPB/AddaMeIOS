//
//  ChatBottomView.swift
//
//
//  Created by Saroar Khandoker on 18.06.2021.
//

import ComposableArchitecture
import SharedModels
import SwiftUI

struct ChatBottomView: View {
  public init(store: Store<ChatState, ChatAction>) {
    self.store = store
  }

  @State var composedMessage = String.empty
  @State var isMicButtonHide = false
  @State var preWordCount: Int = 0
  @State var newLineCount = 1
  @State var placeholderString: String = "Type..."
  @State var tEheight: CGFloat = 40

  public let store: Store<ChatState, ChatAction>

  private func onComment() {
    //    chatData.send()
    //    chatData.clearComposedMessage()
    tEheight = 40
  }

  var body: some View {
    WithViewStore(self.store) { viewStore in
      ZStack {
        VStack {
          //        Spacer()
          HStack {
            TextField(
              "Type..",
              text: viewStore.binding(
                get: { $0.messageToSend },
                send: ChatAction.messageToSendChanged
              )
            )
            .lineLimit(9)
            .font(Font.system(size: 20, weight: .thin, design: .rounded))
            .frame(height: 40)
            .foregroundColor(viewStore.messageToSend == placeholderString ? .gray : .primary)
            .padding([.trailing, .leading], 10)
            .background(RoundedRectangle(cornerRadius: 8).stroke())
            .background(Color.clear)

            //          TextEditor(text: self.$chatData.composedMessage)
            //            .foregroundColor(self.chatData.composedMessage == placeholderString ? .gray : .primary)
            //            .onChange(of: self.chatData.composedMessage, perform: { value in
            //              preWordCount = value.split { $0.isNewline }.count
            //              if preWordCount == newLineCount && preWordCount < 9 {
            //                newLineCount += 1
            //                tEheight += 20
            //              }
            //
            //              if chatData.composedMessage == String.empty {
            //                tEheight = 40
            //              }
            //            })
            //            .lineLimit(9) // its does not work ios 14 and swiftui 2.0
            //            .font(Font.system(size: 20, weight: .thin, design: .rounded))
            //            .frame(height: tEheight)
            //            .onTapGesture {
            //              if self.chatData.composedMessage == placeholderString {
            //                self.chatData.composedMessage = String.empty
            //              }
            //            }
            //            .padding([.trailing, .leading], 10)
            //            .background(RoundedRectangle(cornerRadius: 8).stroke())
            //            .background(Color.clear)

            Button {
              viewStore.send(.sendButtonTapped)
            } label: {
              Image(systemName: "arrow.up")
                // .resizable()
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

// struct ChatBottomView_Previews: PreviewProvider {
//  static var previews: some View {
//    ChatBottomView()
//      .environmentObject(ChatDataHandler())
//  }
// }
