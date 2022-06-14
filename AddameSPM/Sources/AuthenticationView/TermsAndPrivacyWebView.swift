//
//  TermsAndPrivacyWebView.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 07.12.2020.
//

import SwiftUI
import ComposableArchitecture

public struct TermsAndPrivacyState: Equatable {
  public init(
    urlString: String? = nil
  ) {
    self.urlString = urlString
  }

  public var urlString: String?
}

public enum TermsAndPrivacyAction: Equatable {
  case terms
  case privacy
}

public struct TermsAndPrivacyEnvironment {
  public init() {}
}

extension TermsAndPrivacyEnvironment {
  public static let live: TermsAndPrivacyEnvironment = .init()
}

public let termsAndPrivacyReducer = Reducer<
  TermsAndPrivacyState,
  TermsAndPrivacyAction,
  TermsAndPrivacyEnvironment
> { _, action, _ in
  switch action {
  case .terms:
    return .none
  case .privacy:
    return .none
  }
}

public struct TermsAndPrivacyWebView: View {
  @Environment(\.presentationMode) var presentationMode

  public init(store: Store<TermsAndPrivacyState, TermsAndPrivacyAction>) {
    self.store = store
  }

  public let store: Store<TermsAndPrivacyState, TermsAndPrivacyAction>

  public var body: some View {
    WithViewStore(self.store) { viewStore in
      TermsAndPrivacyWebRepresentableView(urlString: viewStore.urlString)
        .overlay(
          Button(
            action: {
              presentationMode.wrappedValue.dismiss()
            },
            label: {
              Image(systemName: "xmark.circle").font(.title)
            }
          )
          .padding(.bottom, 10)
          .padding(),

          alignment: .bottomTrailing
        )
    }
  }
}

struct TermsAndPrivacyWebView_Previews: PreviewProvider {

  static let store = Store(
    initialState: TermsAndPrivacyState(urlString: "http://10.0.1.3:3030/privacy"),
    reducer: termsAndPrivacyReducer, environment: .init()
  )

  static var previews: some View {
    TermsAndPrivacyWebView(store: store)
  }
}
