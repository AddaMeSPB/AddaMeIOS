//
//  Event.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 26.08.2020.
//

import SwiftUI
import CoreLocation
import MapKit

public struct Event: Codable, Identifiable, Equatable {
  public init(
    id: String? = nil, name: String, details: String? = nil,
    imageUrl: String? = nil, duration: Int,
    categories: String, isActive: Bool, addressName: String,
    type: GeoType = .Point, sponsored: Bool? = false,
    overlay: Bool? = false, coordinates: [Double],
    regionRadius: CLLocationDistance? = 1000,
    createdAt: Date? = nil, updatedAt: Date? = nil
  ) {
    self.id = id
    self.name = name
    self.details = details
    self.imageUrl = imageUrl
    self.duration = duration
    self.categories = categories
    self.isActive = isActive
    self.addressName = addressName
    self.type = type
    self.sponsored = sponsored
    self.overlay = overlay
    self.coordinates = coordinates
    self.regionRadius = regionRadius
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }

  public static let draff = Self(
    id: "", name: "",
    details: "", imageUrl: "",
    duration: 22, categories: "",
    isActive: false, addressName: "",
    coordinates: [0.0, 0.0]
  )

  public var id: String?
  public var name: String
  public var details: String?
  public var imageUrl: String?
  public var duration: Int
  public var categories: String
  public var isActive: Bool

  public var addressName: String
  public var type: GeoType = .Point
  public var sponsored: Bool? = false
  public var overlay: Bool? = false
  public var coordinates: [Double]
  public var regionRadius: CLLocationDistance? = 1000

  public var createdAt: Date?
  public var updatedAt: Date?

  public static func == (lhs: Event, rhs: Event) -> Bool {
    lhs.id == rhs.id
  }
}

// MARK: - EventResponse
public struct EventResponse: Codable, Equatable {
  public static func == (lhs: EventResponse, rhs: EventResponse) -> Bool {
    return lhs.items == rhs.items && lhs.metadata == rhs.metadata
  }

  public let items: [Item]
  public var metadata: Metadata = .init(per: 10, total: 10, page: 1)

  public static let emptry = Self(
    items: [],
    metadata: .init(per: 0, total: 0, page: 0)
  )

  public init(
    items: [EventResponse.Item],
    metadata: Metadata = .init(per: 10, total: 10, page: 1)
  ) {
    self.items = items
    self.metadata = metadata
  }

  // MARK: - Item

  public class Item: NSObject, Codable, Identifiable, Comparable {
    public static func < (lhs: EventResponse.Item, rhs: EventResponse.Item) -> Bool {
      return lhs.coordinate < rhs.coordinate && lhs.id < rhs.id
    }

    public init(
      id: String, name: String, categories: String,
      imageUrl: String? = nil, duration: Int, isActive: Bool,
      conversationsId: String, addressName: String,
      details: String? = nil, type: String, sponsored: Bool,
      overlay: Bool, coordinates: [Double], regionRadius: CLLocationDistance? = 1000,
      createdAt: Date, updatedAt: Date
    ) {
      self._id = id
      self.name = name
      self.categories = categories
      self.imageUrl = imageUrl
      self.duration = duration
      self.isActive = isActive
      self.conversationsId = conversationsId
      self.addressName = addressName
      self.details = details
      self.type = type
      self.sponsored = sponsored
      self.overlay = overlay
      self.coordinates = coordinates
      self.regionRadius = regionRadius
      self.createdAt = createdAt
      self.updatedAt = updatedAt
    }

    public static var draff: EventResponse.Item {
      .init(
        id: "", name: "", categories: "",
        duration: 14400, isActive: false,
        conversationsId: "", addressName: "",
        type: "Point", sponsored: false, overlay: false,
        coordinates: [9.9, 8.0], createdAt: Date(), updatedAt: Date()
      )
    }

    public var _id, name, categories: String
    public var imageUrl: String?
    public var duration: Int
    public var isActive: Bool
    public var conversationsId: String
    public var addressName: String
    public var details: String?
    public var type: String
    public var sponsored: Bool
    public var overlay: Bool
    public var coordinates: [Double]
    public var regionRadius: CLLocationDistance? = 1000

    public var createdAt: Date
    public var updatedAt: Date
  }

}

// MARK: - Metadata
public struct Metadata: Codable, Equatable {
  public let per, total, page: Int

  public init(per: Int, total: Int, page: Int) {
    self.per = per
    self.total = total
    self.page = page
  }
}

extension EventResponse.Item: MKAnnotation {
  public var coordinate: CLLocationCoordinate2D { location.coordinate }
  public var title: String? { addressName }
  public var location: CLLocation {
    CLLocation(latitude: coordinates[0], longitude: coordinates[1])
  }

  public var region: MKCoordinateRegion {
    MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius ?? 1000,
      longitudinalMeters: regionRadius ?? 1000
    )
  }

  public var coordinateMongo: CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: self.coordinate.longitude, longitude: self.coordinate.latitude)
  }

  public var coordinatesMongoDouble: [Double] {
    return [coordinates[1], coordinates[0]]
  }

  public var doubleToCoordinate: CLLocation {
    return CLLocation(latitude: coordinates[0], longitude: coordinates[1])
  }

  public func distance(_ currentCLLocation: CLLocation) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      currentCLLocation.distance(from: self.location)
    }
  }

}

extension CLLocation {
  var double: [Double] {
    return [self.coordinate.latitude, self.coordinate.longitude]
  }
}

// swiftlint:disable all
public enum GeoType: String {
  case Point
  case LineString
  case Polygon
  case MultiPoint
  case MultiLineString
  case MultiPolygon
  case GeometryCollection
}

extension GeoType: Encodable {}
extension GeoType: Decodable {}

extension CLLocationCoordinate2D: Equatable, Comparable {
  public static func < (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude < rhs.latitude && lhs.longitude < rhs.longitude
  }

  public static func ==(lhs: Self, rhs: Self) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
  }
}
