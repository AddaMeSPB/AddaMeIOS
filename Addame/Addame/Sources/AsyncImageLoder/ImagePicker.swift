//
//  ImagePicker.swift
//
//
//  Created by Saroar Khandoker on 26.01.2021.
//

import Foundation
import SwiftUI
import UIKit

public struct ImagePicker: UIViewControllerRepresentable {
  @Environment(\.presentationMode) var presentationMode
  @Binding var image: UIImage?

  public init(image: Binding<UIImage?>) {
    _image = image
  }

  public func makeUIViewController(
    context: UIViewControllerRepresentableContext<ImagePicker>
  ) -> UIImagePickerController {
    let picker = UIImagePickerController()
    picker.delegate = context.coordinator
    return picker
  }

  public func updateUIViewController(
    _: UIImagePickerController, context _: UIViewControllerRepresentableContext<ImagePicker>
  ) {}

  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  public class Coordinator: NSObject, UINavigationControllerDelegate,
    UIImagePickerControllerDelegate {
    public let parent: ImagePicker

    public init(_ parent: ImagePicker) {
      self.parent = parent
    }

    public func imagePickerController(
      _: UIImagePickerController,
      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
      if let uiImage = info[.originalImage] as? UIImage {
        parent.image = uiImage
      }

      parent.presentationMode.wrappedValue.dismiss()
    }
  }
}
