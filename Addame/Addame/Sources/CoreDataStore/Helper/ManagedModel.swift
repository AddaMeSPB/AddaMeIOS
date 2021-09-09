//
//  ManagedModel.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 01.12.2020.
//

import CoreData
import Foundation

public typealias APIData = Encodable

protocol ManagedModel: NSFetchRequestResult {
  static var entity: NSEntityDescription { get }
  static var entityName: String { get }
  static var defaultSortDescriptors: [NSSortDescriptor] { get }
  static var defaultPredicate: NSPredicate { get }
}

extension ManagedModel {
  static var defaultSortDescriptors: [NSSortDescriptor] {
    return []
  }

  public static var defaultPredicate: NSPredicate { return NSPredicate(value: true) }

  public static var sortedFetchRequest: NSFetchRequest<Self> {
    let request = NSFetchRequest<Self>(entityName: entityName)
    request.sortDescriptors = defaultSortDescriptors
    return request
  }

  public static func sortedFetchRequest(with predicate: NSPredicate) -> NSFetchRequest<Self> {
    let request = sortedFetchRequest
    guard let existingPredicate = request.predicate else { fatalError("must have predicate") }
    request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
      existingPredicate, predicate
    ])
    return request
  }

  public static func predicate(format: String, _ args: CVarArg...) -> NSPredicate {
    let pre = withVaList(args) { NSPredicate(format: format, arguments: $0) }
    return predicate(pre)
  }

  public static func predicate(_ predicate: NSPredicate) -> NSPredicate {
    return NSCompoundPredicate(andPredicateWithSubpredicates: [defaultPredicate, predicate])
  }

  // swiftlint:disable force_try superfluous_disable_command
  public static func fetch(
    in context: NSManagedObjectContext,
    configurationBlock: (
      NSFetchRequest<Self>
    ) -> Void = { _ in }
  ) -> [Self] {
    let request = NSFetchRequest<Self>(entityName: Self.entityName)
    configurationBlock(request)
    do {
      return try context.fetch(request)
    } catch {
      // print some error
      print(#line, error)
      return []
    }
  }
}

extension ManagedModel where Self: NSManagedObject {
  static var entity: NSEntityDescription { return entity() }

  static var entityName: String { return entity.name! }

  static func findOrCreate(
    in context: NSManagedObjectContext,
    matching predicate: NSPredicate,
    configure: (Self) -> Void
  ) -> Self {
    guard let object = findOrFetch(in: context, matching: predicate) else {
      let newObject: Self = context.insertManaged()
      configure(newObject)
      return newObject
    }
    return object
  }

  static func findOrFetch(in context: NSManagedObjectContext, matching predicate: NSPredicate)
    -> Self? {
    guard let object = materializedObject(in: context, matching: predicate) else {
      return fetch(in: context) { request in
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
      }.first
    }
    return object
  }

  static func fetch(
    in context: NSManagedObjectContext,
    configurationBlock: (NSFetchRequest<Self>) -> Void = { _ in }
  ) -> [Self] {
    let request = NSFetchRequest<Self>(entityName: Self.entityName)
    configurationBlock(request)

    do {
      return try context.fetch(request)
    } catch {
      print(#line, error)
      return []
    }
  }

  // iterates over objects the context currently knows about (registeredObjects)
  // only interested in faults (objects that contain no data), otherwise this operation is expensive
  static func materializedObject(
    in context: NSManagedObjectContext, matching predicate: NSPredicate
  ) -> Self? {
    for object in context.registeredObjects where !object.isFault {
      guard let result = object as? Self, predicate.evaluate(with: result) else { continue }
      return result
    }
    return nil
  }

  func delete() {
    managedObjectContext?.performChanges(inBlock: {
      self.managedObjectContext?.delete(self)
    })
  }

  func copy() {
    managedObjectContext?.performChanges(inBlock: {
      self.managedObjectContext?.copy()
    })
  }
}
