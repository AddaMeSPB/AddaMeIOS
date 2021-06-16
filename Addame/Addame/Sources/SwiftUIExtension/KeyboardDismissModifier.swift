//
//  KeyboardDismissModifier.swift
//  
//
//  Created by Saroar Khandoker on 29.01.2021.
//

import Foundation
import SwiftUI

public struct KeyboardDismissModifier: ViewModifier {

    public func body(content: Content) -> some View {
        content.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

extension TextField {
    /// Dismiss the keyboard when pressing on something different then a form field
    /// - Returns: KeyboardDismissModifier
    public func hideKeyboardOnTap() -> ModifiedContent<Self, KeyboardDismissModifier> {
        return modifier(KeyboardDismissModifier())
    }
}
