import Contacts
import Combine

public struct CombineContacts {
  
  private let contactStore = CNContactStore()
  
  public init() {}
  
  // MARK: - Privacy Access
  
  /// Requests access to the user's contacts.
  ///
  /// - Parameter entityType: Set to CNEntityTypeContacts.
  /// - Returns: Set granted to true if the user allows access and error is nil.
  public func requestAccess(for entityType: CNEntityType) -> AnyPublisher<Bool, ContactError> {

//    return AnyPublisher<Bool, ContactError>.create { subscriber in
//      self.contactStore.requestAccess(for: entityType) { (bool, error) in
//        if let _ = error {
//          subscriber.send(completion: .failure(.entityTypeError))
//        }
//        subscriber.send(bool)
//        subscriber.send(completion: .finished)
//      }
//
//      return AnyCancellable.empty
//    }
    
    return Future<Bool, ContactError> { completion in
      self.contactStore.requestAccess(for: entityType) { (bool, error) in
        if let error = error as? ContactError {
          completion(.failure(error))
        }
        
        completion(.success(bool))
      }
    }
    .eraseToAnyPublisher()
    
  }
  
  // MARK: - Fetching Unified Contacts
  
  /// Fetches all unified contacts matching the specified predicate.
  ///
  /// - Parameters:
  ///   - predicate: The predicate to match against.
  ///   - keys: The properties to fetch in the returned CNContact objects. You should fetch only the properties that you plan to use. Note that you can combine contact keys and contact key descriptors.
  /// - Returns: An array of CNContact objects matching the predicate.
  
  public func unifiedContact(withIdentifier identifier: String, keysToFetch keys: [CNKeyDescriptor]) -> AnyPublisher<CNContact, ContactError> {
    
    return Future<CNContact, ContactError> { completion in
      do {
        completion(.success(try self.contactStore.unifiedContact(withIdentifier: identifier, keysToFetch: keys)) )
      } catch {
        if let error = error as? ContactError {
          completion(.failure(error))
        } else {
          fatalError("\(#line) unifiedContact withIdentifier error \(self)")
        }
      }
      
    }
    .eraseToAnyPublisher()
    
  }
  
  /// Fetches a unified contact for the specified contact identifier.
  ///
  /// - Parameters:
  ///   - identifier: The identifier of the contact to fetch.
  ///   - keys:     The properties to fetch in the returned CNContact object.
  /// - Returns: A unified contact matching or linked to the identifier.
  public func unifiedContacts(matching predicate: NSPredicate, keysToFetch keys: [CNKeyDescriptor] ) -> AnyPublisher<[CNContact], ContactError> {
    
    return Future<[CNContact], ContactError> { completion in
      do {
        completion(.success(try contactStore.unifiedContacts(matching: predicate, keysToFetch: keys)) )
      } catch {
        if let error = error as? ContactError {
          completion(.failure(error))
        } else {
          fatalError("\(#line) unifiedContact matching error \(self)")
        }
      }
    }
    .eraseToAnyPublisher()
  }
  
  // MARK: - Fetching and Saving
  
  /// Fetches all groups matching the specified predicate.
  ///
  /// - Parameter predicate: The predicate to use to fetch the matching groups. Set predicate to nil to match all groups.
  /// - Returns: An array of CNGroup objects that match the predicate.
  public func groups(matching predicate: NSPredicate?) -> AnyPublisher<[CNGroup], ContactError> {
    
    return Future<[CNGroup], ContactError> { completion in
      do {
        completion(.success(try self.contactStore.groups(matching: predicate)))
      } catch {
        if let error = error as? ContactError {
          completion(.failure(error))
        } else {
          fatalError("\(#line) matching error \(self)")
        }
      }
    }
    .eraseToAnyPublisher()
    
  }
  
  /// Fetches all containers matching the specified predicate.
  ///
  /// - Parameter predicate: The predicate to use to fetch matching containers. Set this property to nil to match all containers.
  /// - Returns: An array of CNContainer objects that match the predicate.
  public func containers(matching predicate: NSPredicate?) -> AnyPublisher<[CNContainer], ContactError> {

    return Future<[CNContainer], ContactError> { completion in
      do {
        completion(.success(try self.contactStore.containers(matching: predicate)))
      } catch {
        if let error = error as? ContactError {
          completion(.failure(error))
        } else {
          fatalError("\(#line) matching error \(self)")
        }
      }
    }
    .eraseToAnyPublisher()
    
  }
  
  /// Returns a Boolean value that indicates whether the enumeration of all contacts matching a contact fetch request executed successfully.
  ///
  /// - Parameter fetchRequest: The contact fetch request that specifies the search criteria.
  /// - Returns: true if enumeration of all contacts matching a contact fetch request executes successfully; otherwise, false
  public func enumerateContacts(with fetchRequest: CNContactFetchRequest) -> AnyPublisher<(CNContact, UnsafeMutablePointer<ObjCBool>), ContactError> {
    
    return Future<(CNContact, UnsafeMutablePointer<ObjCBool>), ContactError> { completion in
      do {
           try self.contactStore.enumerateContacts(with: fetchRequest, usingBlock: { (contact, pointer) in
            completion( .success( (contact, pointer) ))
           })
        
      } catch {
        if let error = error as? ContactError {
          completion(.failure(error))
        } else {
          fatalError("\(#line) enumerateContacts error \(self)")
        }
      }
    }
    .eraseToAnyPublisher()
  }
  
  #if os(iOS) || os(OSX)
  
  /// Executes a save request and returns success or failure.
  ///
  /// - Parameter saveRequest: The save request to execute.
  /// - Returns: true if the save request executes successfully; otherwise, false.
  public func execute(_ saveRequest: CNSaveRequest) -> AnyPublisher<Void, Never> {

    return Future<Void, Never> { completion in
      do {
        completion(.success(try self.contactStore.execute(saveRequest)))
      } catch {
        
      }
    }
    .eraseToAnyPublisher()
    
  }
  
  #endif
  
  /// Posted notifications when changes occur in another CNContactStore.
  ///
  /// - Returns: Notification Object
//  public func didChange() -> AnyPublisher<Notification, Never> {
//    // what is best way change rx Observable to conbime in this case AnyPublisher?
//    // return NotificationCenter.default.rx.notification(NSNotification.Name.CNContactStoreDidChange)
//
//    return NotificationCenter.default.post(NSNotification.Name.CNContactStoreDidChange)
//  }
  

}
