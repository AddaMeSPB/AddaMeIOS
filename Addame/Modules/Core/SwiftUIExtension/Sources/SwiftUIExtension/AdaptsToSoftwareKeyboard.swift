//
//  AdaptsToSoftwareKeyboard.swift
//  
//
//  Created by Saroar Khandoker on 05.03.2021.
//

import Foundation
import SwiftUI
import Combine

public struct AdaptsToSoftwareKeyboard: ViewModifier {
  
  @State var currentHeight: CGFloat = 0
  
  public init() {}
  
  public func body(content: Content) -> some View {
    content
      .padding(.bottom, currentHeight)
      .animation(.default)
      .edgesIgnoringSafeArea(currentHeight == 0 ? [] : .bottom)
      .onAppear(perform: subscribeToKeyboardEvents)
  }
  
  private func subscribeToKeyboardEvents() {
    NotificationCenter.Publisher(
      center: NotificationCenter.default,
      name: UIResponder.keyboardWillShowNotification
    ).compactMap { notification in
      notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect
    }.map { rect in
      rect.height
    }.subscribe(Subscribers.Assign(object: self, keyPath: \.currentHeight))
    
    NotificationCenter.Publisher(
      center: NotificationCenter.default,
      name: UIResponder.keyboardWillHideNotification
    ).compactMap { notification in
      CGFloat.zero
    }.subscribe(Subscribers.Assign(object: self, keyPath: \.currentHeight))
  }
}

