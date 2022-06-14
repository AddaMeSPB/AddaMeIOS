//
//  PhoneNumberTextFieldView.swift
//  
//
//  Created by Saroar Khandoker on 15.09.2021.
//

import PhoneNumberKit
import SwiftUI

public struct PhoneNumberTextFieldView: UIViewRepresentable, Equatable {
  public static func == (lhs: PhoneNumberTextFieldView, rhs: PhoneNumberTextFieldView) -> Bool {
    return lhs.isValid == rhs.isValid && lhs.phoneNumber == rhs.phoneNumber
  }

  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  @Binding var phoneNumber: String
  @Binding var isValid: Bool

  let phoneTextField = PhoneNumberTextField()

  public func makeUIView(context: Context) -> PhoneNumberTextField {
    phoneTextField.withExamplePlaceholder = true
    phoneTextField.withFlag = true
    phoneTextField.withPrefix = true
    phoneTextField.withExamplePlaceholder = true
    // phoneTextField.placeholder = "Enter phone number"
    phoneTextField.becomeFirstResponder()
    phoneTextField.addTarget(
      context.coordinator, action: #selector(Coordinator.onTextUpdate), for: .editingChanged)
    return phoneTextField
  }

  public func getCurrentText() {
    guard let phoneText = phoneTextField.text else {
      return
    }
    phoneNumber = phoneText
  }

  public func updateUIView(_: PhoneNumberTextField, context _: Context) {}

  public class Coordinator: NSObject, UITextFieldDelegate {
    var control: PhoneNumberTextFieldView

    init(_ control: PhoneNumberTextFieldView) {
      self.control = control
    }

    @objc func onTextUpdate(textField _: UITextField) {
      control.isValid = control.phoneTextField.isValidNumber
    }
  }
}
