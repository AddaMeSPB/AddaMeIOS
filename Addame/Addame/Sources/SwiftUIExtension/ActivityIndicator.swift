//
//  ActivityIndicator.swift
//  
//
//  Created by Saroar Khandoker on 21.04.2021.
//

import SwiftUI

public struct ActivityIndicator: UIViewRepresentable {
  public init() {}

  public func makeUIView(context: Context) -> UIActivityIndicatorView {
    let view = UIActivityIndicatorView(style: .large)
    view.color = .systemBackground
    view.startAnimating()
    return view
  }

  public func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {}
}
