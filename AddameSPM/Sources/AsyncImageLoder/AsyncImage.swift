//
//  AsyncImage.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 31.08.2020.
//

import SwiftUI

public struct AsyncImage<Placeholder: View>: View {
  @StateObject private var loader: ImageLoader
  private var placeholder: Placeholder
  private var image: (UIImage) -> Image

  public init(
    url: URL,
    @ViewBuilder placeholder: () -> Placeholder,
    @ViewBuilder image: @escaping (UIImage) -> Image = Image.init(uiImage:)
  ) {
    self.placeholder = placeholder()
    self.image = image
    _loader = StateObject(
      wrappedValue: ImageLoader(
        url: url,
        cache: Environment(\.imageCache).wrappedValue
      )
    )
  }

  public var body: some View {
    content
      .onAppear(perform: loader.load)
  }

  private var content: some View {
    Group {
      if let loaderImage = loader.image {
        image(loaderImage)
      } else {
        placeholder
      }
    }
  }
}
