//
//  MapView.swift
//  
//
//  Created by Saroar Khandoker on 05.07.2021.
//

import MapKit
import SwiftUI

#if os(macOS)
  public typealias ViewRepresentable = NSViewRepresentable
#elseif os(iOS)
  public typealias ViewRepresentable = UIViewRepresentable
#endif

public struct MapView: ViewRepresentable {
  let pointsOfInterest: [PointOfInterest]
  @Binding var region: CoordinateRegion?
  let isEventDetailsView: Bool

  public init(
    pointsOfInterest: [PointOfInterest],
    region: Binding<CoordinateRegion?>,
    isEventDetailsView: Bool = false
  ) {
    self.pointsOfInterest = pointsOfInterest
    self._region = region
    self.isEventDetailsView = isEventDetailsView
  }

  #if os(macOS)
    public func makeNSView(context: Context) -> MKMapView {
      self.makeView(context: context)
    }
  #elseif os(iOS)
    public func makeUIView(context: Context) -> MKMapView {
      self.makeView(context: context)
    }
  #endif

  #if os(macOS)
    public func updateNSView(_ mapView: MKMapView, context: NSViewRepresentableContext<MapView>) {
      self.updateView(mapView: mapView, delegate: context.coordinator)
    }
  #elseif os(iOS)
    public func updateUIView(_ mapView: MKMapView, context: Context) {
      self.updateView(mapView: mapView, delegate: context.coordinator)
    }
  #endif

  public func makeCoordinator() -> MapViewCoordinator {
    MapViewCoordinator(self)
  }

  private func makeView(context: Context) -> MKMapView {
    let mapView = MKMapView(frame: .zero)
    mapView.showsUserLocation = true

    if isEventDetailsView {
//      mapView.isZoomEnabled = false
      mapView.isScrollEnabled = false
    }

    return mapView
  }

  private func updateView(mapView: MKMapView, delegate: MKMapViewDelegate) {
    mapView.delegate = delegate

    if let region = self.region {
      mapView.setRegion(region.asMKCoordinateRegion, animated: true)
    }

    let currentlyDisplayedPOIs = mapView.annotations.compactMap { $0 as? PointOfInterestAnnotation }
      .map { $0.pointOfInterest }

    let addedPOIs = Set(pointsOfInterest).subtracting(currentlyDisplayedPOIs)
    let removedPOIs = Set(currentlyDisplayedPOIs).subtracting(pointsOfInterest)

    let addedAnnotations = addedPOIs.map(PointOfInterestAnnotation.init(pointOfInterest:))
    let removedAnnotations = mapView.annotations.compactMap { $0 as? PointOfInterestAnnotation }
      .filter { removedPOIs.contains($0.pointOfInterest) }

    mapView.removeAnnotations(removedAnnotations)
    mapView.addAnnotations(addedAnnotations)

  }
}

private class PointOfInterestAnnotation: NSObject, MKAnnotation {
  let pointOfInterest: PointOfInterest

  init(pointOfInterest: PointOfInterest) {
    self.pointOfInterest = pointOfInterest
  }

  var coordinate: CLLocationCoordinate2D { self.pointOfInterest.coordinate }
  var subtitle: String? { self.pointOfInterest.subtitle }
  var title: String? { self.pointOfInterest.title }
}

public class MapViewCoordinator: NSObject, MKMapViewDelegate {
  var mapView: MapView

  init(_ control: MapView) {
    self.mapView = control
  }

  public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    self.mapView.region = CoordinateRegion(coordinateRegion: mapView.region)
  }
}

public struct PointOfInterest: Equatable, Hashable {
  public let coordinate: CLLocationCoordinate2D
  public let subtitle: String?
  public let title: String?

  public init(
    coordinate: CLLocationCoordinate2D,
    subtitle: String?,
    title: String?
  ) {
    self.coordinate = coordinate
    self.subtitle = subtitle
    self.title = title
  }
}

public struct CoordinateRegion: Equatable {
  public var center: CLLocationCoordinate2D
  public var span: MKCoordinateSpan

  public init(
    center: CLLocationCoordinate2D,
    span: MKCoordinateSpan
  ) {
    self.center = center
    self.span = span
  }

  public init(coordinateRegion: MKCoordinateRegion) {
    self.center = coordinateRegion.center
    self.span = coordinateRegion.span
  }

  public var asMKCoordinateRegion: MKCoordinateRegion {
    .init(center: self.center, span: self.span)
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.center.latitude == rhs.center.latitude
      && lhs.center.longitude == rhs.center.longitude
      && lhs.span.latitudeDelta == rhs.span.latitudeDelta
      && lhs.span.longitudeDelta == rhs.span.longitudeDelta
  }
}

extension PointOfInterest {
  // NB: CLLocationCoordinate2D doesn't conform to Equatable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.coordinate.latitude == rhs.coordinate.latitude
      && lhs.coordinate.longitude == rhs.coordinate.longitude
      && lhs.subtitle == rhs.subtitle
      && lhs.title == rhs.title
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(coordinate.latitude)
    hasher.combine(coordinate.longitude)
    hasher.combine(title)
    hasher.combine(subtitle)
  }
}
