//
//  DynamicHeightTextField.swift
//  DynamicHeightTextField
//
//  Created by Saroar Khandoker on 29.07.2021.
//

import SwiftUI

public struct DynamicHeightTextField: UIViewRepresentable {

  public init(text: Binding<String>, height: Binding<CGFloat>) {
    self._text = text
    self._height = height
  }

  @Binding var text: String
  @Binding var height: CGFloat

  public func makeUIView(context: Context) -> UITextView {
    let textView = UITextView()

    textView.isScrollEnabled = true
    textView.alwaysBounceVertical = false
    textView.isEditable = true
    textView.isUserInteractionEnabled = true

    textView.textColor = UIColor.red
    textView.font = UIFont(name: "Courier", size: 20)

    textView.text = text
    textView.backgroundColor = UIColor.clear

    context.coordinator.textView = textView
    textView.delegate = context.coordinator
    textView.layoutManager.delegate = context.coordinator

    return textView
  }

  public func updateUIView(_ uiView: UITextView, context: Context) {
    uiView.text = text
  }

  public func makeCoordinator() -> Coordinator {
    return Coordinator(dynamicSizeTextField: self)
  }
}

public class Coordinator: NSObject, UITextViewDelegate, NSLayoutManagerDelegate {

  var dynamicHeightTextField: DynamicHeightTextField

  weak var textView: UITextView?

  init(dynamicSizeTextField: DynamicHeightTextField) {
    self.dynamicHeightTextField = dynamicSizeTextField
  }

  public func textViewDidChange(_ textView: UITextView) {
    self.dynamicHeightTextField.text = textView.text
  }

  public func textView(
    _ textView: UITextView,
    shouldChangeTextIn range: NSRange,
    replacementText text: String
  ) -> Bool {
    if text == "\n" {
      textView.resignFirstResponder()
      return false
    }
    return true
  }

  public func layoutManager(
    _ layoutManager: NSLayoutManager,
    didCompleteLayoutFor textContainer: NSTextContainer?,
    atEnd layoutFinishedFlag: Bool
  ) {

    DispatchQueue.main.async { [weak self] in
      guard let textView = self?.textView else {
        return
      }
      let size = textView.sizeThatFits(textView.bounds.size)
      if self?.dynamicHeightTextField.height != size.height {
        self?.dynamicHeightTextField.height = size.height
      }
    }

  }
}
