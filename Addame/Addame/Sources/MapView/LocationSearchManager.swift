//
//  LocationSearchManager.swift
//  
//
//  Created by Saroar Khandoker on 31.07.2021.
//

import Foundation
import CoreLocation
import MapKit
import SwiftUI
import Combine
import ComposableArchitecture
import SwiftUIExtension

public struct LocalSearchManager {

  public enum Action: Equatable, Hashable {
    case completerDidUpdateResults(completer: MKLocalSearchCompleter)
    case completer(MKLocalSearchCompleter, didFailWithError: Error)
  }

  public struct Error: Swift.Error, Equatable, Hashable {
    public let error: NSError?

    public init(_ error: Swift.Error?) {
      self.error = error as NSError?
    }
  }

  var create: (
    AnyHashable, MKLocalSearchCompleter.ResultType
  ) -> Effect<Action, Never> = { _, _ in _unimplemented("create") }

  var destroy: (AnyHashable) -> Effect<Never, Never> = { _ in _unimplemented("destroy") }

  var query: (AnyHashable, String) -> Effect<Never, Never> = { _, _ in _unimplemented("query") }

  public func create(id: AnyHashable, resultTypes: MKLocalSearchCompleter.ResultType) -> Effect<Action, Never> {
    create(id, resultTypes)
  }

  public func destroy(id: AnyHashable) -> Effect<Never, Never> {
    destroy(id)
  }

  public func query(id: AnyHashable, fragment: String) -> Effect<Never, Never> {
    query(id, fragment)
  }
}

public extension LocalSearchManager {
  static let live: LocalSearchManager = { () -> LocalSearchManager in

    var manager = LocalSearchManager()

    manager.create = { id, resultTypes in
      .run { subscriber in
        let localSearchCompleter = MKLocalSearchCompleter()
        let delegate = LocalSearchManagerDelegate(subscriber)
        localSearchCompleter.resultTypes = resultTypes
        localSearchCompleter.delegate = delegate

        dependencies[id] = Dependencies(
          delegate: delegate,
          localSearchCompleter: localSearchCompleter,
          subscriber: subscriber
        )

        return AnyCancellable {
          dependencies[id] = nil
        }
      }
    }

    manager.query = { id, fragment in
      .fireAndForget {
        dependencies[id]?.localSearchCompleter.queryFragment = fragment
      }
    }

    manager.destroy = { id in
      .fireAndForget {
        dependencies[id] = nil
      }
    }

    return manager
  }()
}

private struct Dependencies {
  let delegate: LocalSearchManagerDelegate
  let localSearchCompleter: MKLocalSearchCompleter
  let subscriber: Effect<LocalSearchManager.Action, Never>.Subscriber
}

private var dependencies: [AnyHashable: Dependencies] = [:]

// MARK: - Delegate
private class LocalSearchManagerDelegate: NSObject, MKLocalSearchCompleterDelegate {
  let subscriber: Effect<LocalSearchManager.Action, Never>.Subscriber

  init(_ subscriber: Effect<LocalSearchManager.Action, Never>.Subscriber) {
    self.subscriber = subscriber
  }

  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
    subscriber.send(.completerDidUpdateResults(completer: completer))
  }

  func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
    subscriber.send(.completer(completer, didFailWithError: LocalSearchManager.Error(error)))
  }

}

#if DEBUG
import Foundation

public extension LocalSearchManager {
  static func unimplemented() -> Self {
    Self()
  }
}

#endif

// MARK: - Unimplemented
// swiftlint:disable identifier_name
public func _unimplemented(
  _ function: StaticString, file: StaticString = #file, line: UInt = #line
) -> Never {
  fatalError(
        """
        `\(function)` was called but is not implemented. Be sure to provide an implementation for
        this endpoint when creating the mock.
        """,
        file: file,
        line: line
  )
}
