//
//  NavigationLink+Store.swift
//  
//
//  Created by Saroar Khandoker on 16.04.2021.
//

import ComposableArchitecture
import SwiftUI

extension NavigationLink {
  /// Creates `NavigationLink` using a `Store` with an optional `State`.
  ///
  /// - Link is active if `State` is non-`nil` and inactive when it's `nil`.
  /// - Link's destination is generated using last non-`nil` state value.
  ///
  /// - Parameters:
  ///   - store: A store with optional state.
  ///   - destination: A closure that creates link's destination view.
  ///   - destinationStore: A store with non-optional state.
  ///   - action: A closure invoked when the link is activated or deactivated.
  ///   - isActive: Determines if the link is active or inactive.
  ///   - label: The link's label.
  /// - Returns: Navigation link wrapped in a `WithViewStore`.
  static func store<State, Action, DestinationContent>(
    _ store: Store<State?, Action>,
    destination: @escaping (_ destinationStore: Store<State, Action>) -> DestinationContent,
    action: @escaping (_ isActive: Bool) -> Void,
    label: @escaping () -> Label
  ) -> some View
  where DestinationContent: View,
        Destination == IfLetStore<State, Action, DestinationContent?>
  {
    WithViewStore(store.scope(state: { $0 != nil })) { viewStore in
      NavigationLink(
        destination: IfLetStore(
          store.scope(state: replayNonNil()),
          then: destination
        ),
        isActive: Binding(
          get: { viewStore.state },
          set: action
        ),
        label: label
      )
    }
  }
}

extension View {
  /// Adds `NavigationLink` without a label, using `Store` with an optional `State`.
  ///
  /// - Link is active if `State` is non-`nil` and inactive when it's `nil`.
  /// - Link's destination is generated using last non-`nil` state value.
  ///
  /// - Parameters:
  ///   - store: store with optional state
  ///   - destination: closure that creates link's destination view
  ///   - destinationStore: store with non-optional state
  ///   - onDismiss: closure invoked when link is deactivated
  /// - Returns: view with label-less `NavigationLink` added as a background view
  public func navigate<State, Action, DestinationContent>(
    using store: Store<State?, Action>,
    destination: @escaping (_ destinationStore: Store<State, Action>) -> DestinationContent,
    onDismiss: @escaping () -> Void
  ) -> some View
  where DestinationContent: View
  {
    background(
      NavigationLink.store(
        store,
        destination: destination,
        action: { isActive in
          if isActive == false {
            onDismiss()
          }
        },
        label: EmptyView.init
      )
    )
  }
}

/// Converts a closure `(A) -> B?` to a closure that returns last non-`nil` `B` returned by the input closure.
///
/// Based on a code from [Thomvis/Construct repository](https://github.com/Thomvis/Construct/blob/f165fd005cd939560c1a4eb8d6ee55075a52685d/Construct/Foundation/Memoize.swift)
///
/// - Parameter inputClosure: The input closure.
/// - Returns: Modified closure.
func replayNonNil<A, B>(_ inputClosure: @escaping (A) -> B?) -> (A) -> B? {
  var lastNonNilOutput: B? = nil
  return { inputValue in
    guard let outputValue = inputClosure(inputValue) else {
      return lastNonNilOutput
    }
    lastNonNilOutput = outputValue
    return outputValue
  }
}

/// Creates a closure (T?) -> T? that returns last non-`nil` T passed to it.
///
/// - Returns: The closure.
func replayNonNil<T>() -> (T?) -> T? {
  replayNonNil { $0 }
}
