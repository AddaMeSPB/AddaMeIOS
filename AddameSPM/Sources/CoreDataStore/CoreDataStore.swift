import CoreData

public struct CoreDataStore {
  public static let shared = CoreDataStore()

  public var moc: NSManagedObjectContext {
    return container.viewContext
  }

  public let container: NSPersistentContainer

  @discardableResult
  public init?(inMemory: Bool = false) {
    guard let modelURL = Bundle.module.url(forResource: "AddaModel", withExtension: ".momd") else {
      return nil
    }
    guard let model = NSManagedObjectModel(contentsOf: modelURL) else { return nil }

    container = NSPersistentContainer(name: "AddaModel", managedObjectModel: model)

    if inMemory, let container = container.persistentStoreDescriptions.first {
      container.url = URL(fileURLWithPath: "/dev/null")
    }

    container.loadPersistentStores(completionHandler: { _, error in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })

    container.viewContext.automaticallyMergesChangesFromParent = true
    container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
  }

  // MARK: - Core Data Saving support

  public func saveContext() {
    let context = container.viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
}
