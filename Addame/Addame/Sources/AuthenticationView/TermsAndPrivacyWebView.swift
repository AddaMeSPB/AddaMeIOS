//
//  TermsAndPrivacyWebView.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 07.12.2020.
//

import SwiftUI

public struct TermsAndPrivacyWebView: View {
  @Environment(\.presentationMode) var presentationMode
  let urlString: String

  public var body: some View {
    TermsAndPrivacyWebRepresentableView(urlString: urlString)
      .overlay(
        Button(action: {
          presentationMode.wrappedValue.dismiss()
        }, label: {
          Image(systemName: "xmark.circle").font(.title)
        })
        .padding(.bottom, 10)
        .padding(),

        alignment: .bottomTrailing
      )

  }
}

struct TermsAndPrivacyWebView_Previews: PreviewProvider {
    static var previews: some View {
      TermsAndPrivacyWebView(urlString: "http://10.0.1.3:3030/privacy")
    }
}
