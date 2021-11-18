//
//  HidableTabView.swift
//  
//
//  Created by Saroar Khandoker on 12.11.2021.
//

import SwiftUI

public struct HidableTabView<SelectionValue, Content>: View where SelectionValue: Hashable, Content: View {
  @Binding var isHidden: Bool
  let selection: Binding<SelectionValue>?
  let content: () -> Content

  @State private var currentTabBarHeight: CGFloat = 0

  public init(
    isHidden: Binding<Bool>,
    selection: Binding<SelectionValue>?,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self._isHidden = isHidden
    self.selection = selection
    self.content = content
  }

  public init(
    isHidden: Binding<Bool>,
    @ViewBuilder content: @escaping () -> Content
  ) where SelectionValue == Int {
    self._isHidden = isHidden
    self.selection = nil
    self.content = content
  }

  public var body: some View {
    tabView
      .stackNavigationViewStyle()
      .padding(.bottom, isHidden ? -self.currentTabBarHeight : 0)

  }

  @ViewBuilder var tabView: some View {
    if selection != nil {
      TabView(selection: self.selection!) { self._content }
    } else {
      TabView { self._content }
    }
  }

  // swiftlint:disable identifier_name
  @ViewBuilder var _content: some View {
    self.content()
      .background(tabBarHeightReader)
  }

  var screenBottomSafeAreaInset: CGFloat {
    (UIApplication.shared.windows.first { $0.isKeyWindow }?.safeAreaInsets.bottom ?? 34)
  }

  var tabBarHeightReader: some View {
    GeometryReader { proxy in
      Color.clear
        .onAppear {
          self.currentTabBarHeight = proxy.safeAreaInsets.bottom + screenBottomSafeAreaInset
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
          self.currentTabBarHeight = proxy.safeAreaInsets.bottom + screenBottomSafeAreaInset
        }
    }
  }
}
