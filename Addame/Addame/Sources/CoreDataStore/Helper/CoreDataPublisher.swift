//
// CoreDataPublisher.swift
//  
//
//  Created by Saroar Khandoker on 30.03.2021.
//

import Combine
import CoreData
import Foundation

public class CoreDataPublisher<Entity>: NSObject, NSFetchedResultsControllerDelegate, Publisher where Entity: NSManagedObject {
  public typealias Output = [Entity]
  public typealias Failure = Error
  
  private let request: NSFetchRequest<Entity>
  private let context: NSManagedObjectContext
  private let subject: CurrentValueSubject<[Entity], Failure>
  private var resultController: NSFetchedResultsController<NSManagedObject>?
  private var subscriptions = 0
  
  public init(request: NSFetchRequest<Entity>, context: NSManagedObjectContext) {
    if request.sortDescriptors == nil { request.sortDescriptors = [] }
    self.request = request
    self.context = context
    subject = CurrentValueSubject([])
    super.init()
  }
  
  public func receive<S>(subscriber: S)
  where S: Subscriber, CoreDataPublisher.Failure == S.Failure, CoreDataPublisher.Output == S.Input {
    var start = false
    
    objc_sync_enter(self)
    subscriptions += 1
    start = subscriptions == 1
    objc_sync_exit(self)
    
    if start {
      let controller = NSFetchedResultsController(
        fetchRequest: request,
        managedObjectContext: context,
        sectionNameKeyPath: nil, cacheName: nil
      )
      controller.delegate = self
      
      do {
        try controller.performFetch()
        let result = controller.fetchedObjects ?? []
        subject.send(result)
      } catch {
        subject.send(completion: .failure(error))
      }
      
      resultController = controller as? NSFetchedResultsController<NSManagedObject>
    }
    
    CoreDataSubscription(fetchPublisher: self, subscriber: AnySubscriber(subscriber))
  }
  
  public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    let result = controller.fetchedObjects as? [Entity] ?? []
    subject.send(result)
  }
  
  private func dropSubscription() {
    objc_sync_enter(self)
    subscriptions -= 1
    let stop = subscriptions == 0
    objc_sync_exit(self)
    
    if stop {
      resultController?.delegate = nil
      resultController = nil
    }
  }
  
  private class CoreDataSubscription: Subscription {
    private var fetchPublisher: CoreDataPublisher?
    private var cancellable: AnyCancellable?
    
    @discardableResult
    init(fetchPublisher: CoreDataPublisher, subscriber: AnySubscriber<Output, Failure>) {
      self.fetchPublisher = fetchPublisher
      
      subscriber.receive(subscription: self)
      
      cancellable = fetchPublisher.subject.sink(receiveCompletion: { completion in
        subscriber.receive(completion: completion)
      }, receiveValue: { value in
        _ = subscriber.receive(value)
      })
    }
    
    func request(_ demand: Subscribers.Demand) {}
    
    func cancel() {
      cancellable?.cancel()
      cancellable = nil
      fetchPublisher?.dropSubscription()
      fetchPublisher = nil
    }

  }
  
}

