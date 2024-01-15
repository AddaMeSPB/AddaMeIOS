//
//  LocationSearchManager.swift
//
//
//  Created by Saroar Khandoker on 31.07.2021.
//

import Combine
import CoreLocation
import Foundation
import MapKit
import SwiftUI
import SwiftUIExtension
import Dependencies

public struct LocalSearchManager {

    public enum Action: Equatable, Hashable {
        case completerDidUpdateResults(MKLocalSearchCompleter)
        case completer(MKLocalSearchCompleter, didFailWithError: Error)
    }

    public struct Error: Swift.Error, Equatable, Hashable {
        public let error: NSError?
        public init(_ error: Swift.Error?) {
            self.error = error as NSError?
        }
    }

    var create: (AnyHashable, MKLocalSearchCompleter.ResultType, CLLocationCoordinate2D, CLLocationDistance) async -> Action
        = { _, _, _, _ in _unimplemented("create") }
    
    var destroy: (AnyHashable) -> Void = { _ in _unimplemented("destroy") }

    var query: (AnyHashable, String) -> Void = { _, _ in _unimplemented("query") }

    public func create(
        id: AnyHashable,
        resultTypes: MKLocalSearchCompleter.ResultType,
        center: CLLocationCoordinate2D,
        radius: CLLocationDistance
    ) async -> Action {
        await create(id, resultTypes, center, radius)
    }

    public func destroy(id: AnyHashable) {
        destroy(id)
    }

    public func query(id: AnyHashable, fragment: String) {
        query(id, fragment)
    }
}

private var dependencies: [AnyHashable: Dependencies] = [:]

private struct Dependencies {
    let delegate: LocalSearchManagerDelegate
    let localSearchCompleter: MKLocalSearchCompleter
}

@MainActor
private class LocalSearchManagerDelegate: NSObject, MKLocalSearchCompleterDelegate {
    let continuation: CheckedContinuation<LocalSearchManager.Action, Never>

    init(continuation: CheckedContinuation<LocalSearchManager.Action, Never>) {
        self.continuation = continuation
    }

    nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        continuation.resume(returning: .completerDidUpdateResults(completer))
    }

    nonisolated func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Swift.Error) {
        continuation.resume(returning: .completer(completer, didFailWithError: LocalSearchManager.Error(error)))
    }
}

extension LocalSearchManager {
    public static let live: LocalSearchManager = {
        var manager = LocalSearchManager()

        manager.create = { id, resultTypes, center, radius in
            await withCheckedContinuation { continuation in
                Task { @MainActor in
                    let localSearchCompleter = MKLocalSearchCompleter()
                    localSearchCompleter.resultTypes = resultTypes
                    localSearchCompleter.region = MKCoordinateRegion(center: center, latitudinalMeters: radius, longitudinalMeters: radius)

                    let delegate = LocalSearchManagerDelegate(continuation: continuation)
                    localSearchCompleter.delegate = delegate

                    // Store localSearchCompleter and delegate in dependencies dictionary
                    dependencies[id] = Dependencies(delegate: delegate, localSearchCompleter: localSearchCompleter)
                }
            }
        }

        // have to add .debounce(for: .milliseconds(150), scheduler: RunLoop.main, options: nil)
        manager.query = { id, fragment in
            DispatchQueue.main.async {
                dependencies[id]?.localSearchCompleter.queryFragment = fragment
            }
        }

        manager.destroy = { id in
            DispatchQueue.main.async {
                dependencies[id] = nil
            }
        }

        return manager
    }()
}


extension LocalSearchManager {
    public static let failing: LocalSearchManager = {
        var manager = LocalSearchManager()

        manager.create = { _, _, _, _ in
            // Simulate a failure in creation by returning a failure action
            let completer = MKLocalSearchCompleter()
            let error = NSError(domain: "com.example.error", code: 1, userInfo: [NSLocalizedDescriptionKey: "Creation Failed"])
            return .completer(completer, didFailWithError: LocalSearchManager.Error(error))
        }

        manager.query = { _, _ in
            // In the failing case, we do nothing as the query is supposed to fail
        }

        manager.destroy = { _ in
            // In the failing case, we do nothing as destroy is a cleanup operation
        }

        return manager
    }()
}

extension LocalSearchManager {
    public static let previewValue: LocalSearchManager = {
        var manager = LocalSearchManager()

        manager.create = { _, _, _, _ in
            // Return a static, predictable action with a default MKLocalSearchCompleter
            let completer = MKLocalSearchCompleter()
            // Optionally configure your completer with mock data
            return .completerDidUpdateResults(completer)
        }

        manager.query = { id, fragment in
            // Simulate a query result for previews
            // For example, you can trigger the completerDidUpdateResults action
            // with a predefined set of results
            let mockCompleter = MKLocalSearchCompleter()
            // Configure your mockCompleter with static results based on the fragment
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                // Simulate a delay in fetching results
                dependencies[id]?.delegate.completerDidUpdateResults(mockCompleter)
            }
        }

        manager.destroy = { id in
            // Handle destruction in a way suitable for previews
            // For instance, clean up any static or mock data
        }

        return manager
    }()
}



#if DEBUG
  import Foundation

  extension LocalSearchManager {
    public static func unimplemented() -> Self {
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

extension LocalSearchManagerKey: DependencyKey {
    public static var liveValue: LocalSearchManager = .live
    public static let previewValue: LocalSearchManager = .previewValue
}

public enum LocalSearchManagerKey: TestDependencyKey {
    public static let testValue = LocalSearchManager.failing
}

extension DependencyValues {
  var localSearchManager: LocalSearchManager {
    get { self[LocalSearchManagerKey.self] }
    set { self[LocalSearchManagerKey.self] = newValue }
  }
}

//final class LocalSearchService {
//    let localSearchPublisher = PassthroughSubject<[MKMapItem], Never>()
//    private let center: CLLocationCoordinate2D
//    private let radius: CLLocationDistance
//
//    init(in center: CLLocationCoordinate2D,
//         radius: CLLocationDistance = 350_000) {
//        self.center = center
//        self.radius = radius
//    }
//
//    public func searchCities(searchText: String) {
//        request(resultType: .address, searchText: searchText)
//    }
//
//    public func searchPointOfInterests(searchText: String) {
//        request(searchText: searchText)
//    }
//
//    private func request(
//        resultType: MKLocalSearch.ResultType = .pointOfInterest,
//        searchText: String
//    ) {
//        let request = MKLocalSearch.Request()
//        request.naturalLanguageQuery = searchText
//        request.pointOfInterestFilter = .includingAll
//        request.resultTypes = resultType
//        request.region = MKCoordinateRegion(center: center,
//                                            latitudinalMeters: radius,
//                                            longitudinalMeters: radius)
//        let search = MKLocalSearch(request: request)
//
//        search.start { [weak self](response, _) in
//            guard let response = response else {
//                return
//            }
//
//            self?.localSearchPublisher.send(response.mapItems)
//        }
//    }
//}
