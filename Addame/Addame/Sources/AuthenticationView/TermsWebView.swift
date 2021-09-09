//
//  TermsAndPrivacyWebView.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 07.12.2020.
//

import SwiftUI
import WebKit

public struct TermsAndPrivacyWebRepresentableView: UIViewRepresentable {
  let urlString: String?

  public func makeUIView(context _: Context) -> WKWebView {
    return WKWebView()
  }

  public func updateUIView(_ uiView: WKWebView, context _: Context) {
    if let safeString = urlString, let url = URL(string: safeString) {
      let request = URLRequest(url: url)
      uiView.load(request)
    }
  }
}
