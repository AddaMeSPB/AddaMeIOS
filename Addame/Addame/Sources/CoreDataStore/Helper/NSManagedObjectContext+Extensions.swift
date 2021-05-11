//
//  NSManagedObjectContext+Extensions.swift
//  AddaMeIOS
//
//  Created by Saroar Khandoker on 01.12.2020.
//

import CoreData

extension NSManagedObjectContext {

    // generic A is a subtype of NSManagedObject and conforms to ManagedModel
    func insertManaged<A: NSManagedObject>() -> A where A: ManagedModel {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: A.entityName, into: self) as? A else { fatalError("Trying to insert object with incorrect type") }
        return obj
    }

    func insertObject<A: NSManagedObject>() -> A where A: ManagedModel {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: A.entityName, into: self) as? A else {
            fatalError("Wrong object type")
        }
        return obj
    }

    func addContextObserver(forName name:NSNotification.Name, handler: @escaping (Notification) -> Void ) -> NSObjectProtocol {
        let observer = NotificationCenter.default.addObserver(forName: name, object: self, queue: nil) { (notification) in
            handler(notification)
        }
        return observer
    }

    func saveOrRollback() -> Bool {
        do {
            try save()
            return true
        } catch {
            rollback()
            return false
        }
    }

    func performChanges(inBlock: @escaping () -> Void) {
        perform {
            inBlock()
            _ = self.saveOrRollback()
        }
    }

    func performMerge(fromContextDidSave notification:Notification) {
        perform {
            self.mergeChanges(fromContextDidSave: notification)
        }
    }
}

extension NSManagedObject {
    typealias OnChange = (ChangeType) -> Void

    func observe(_ onChange: @escaping OnChange) -> NotificationToken {
        return NotificationToken(object: self, onChange: onChange)
    }

    public enum ChangeType {
        case change([String : Any])
        case deleted
    }

    public class NotificationToken {
        let onChange: OnChange
        let object: NSManagedObject

        init(object: NSManagedObject, onChange: @escaping OnChange) {
            self.object = object
            self.onChange = onChange
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(contextObjectsDidChange(_:)),
                                                   name: Notification.Name.NSManagedObjectContextObjectsDidChange,
                                                   object: object.managedObjectContext)
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }

        @objc
        func contextObjectsDidChange(_ notification: Notification) {
            if let objects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> {
                if objects.contains(object) {
                    onChange(.change(object.changedValuesForCurrentEvent()))
                }
            }
            if let objects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
                if objects.contains(object) {
                    onChange(.change(object.changedValuesForCurrentEvent()))
                }
            }
            if let objects = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject> {
                if objects.contains(object) {
                    onChange(.deleted)
                }
            }
            if let objects = notification.userInfo?[NSRefreshedObjectsKey] as? Set<NSManagedObject> {
                if objects.contains(object) {
                    onChange(.change(object.changedValuesForCurrentEvent()))
                }
            }
            if let objects = notification.userInfo?[NSInvalidatedObjectsKey] as? Set<NSManagedObject> {
                if objects.contains(object) {
                    onChange(.deleted)
                }
            }
            if notification.userInfo?[NSInvalidatedAllObjectsKey] != nil {
                onChange(.deleted)
            }
        }
    }
}

