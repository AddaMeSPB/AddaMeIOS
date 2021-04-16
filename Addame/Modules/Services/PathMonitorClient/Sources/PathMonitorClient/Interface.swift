import Combine
import Network

public struct NetworkPath {
  public var status: NWPath.Status

  public init(status: NWPath.Status) {
    self.status = status
  }
}

extension NetworkPath {
  public init(rawValue: NWPath) {
    self.status = rawValue.status
  }
}

public struct PathMonitorClient {
  public var networkPathPublisher: AnyPublisher<NetworkPath, Never>

  public init(
    networkPathPublisher: AnyPublisher<NetworkPath, Never>
  ) {
    self.networkPathPublisher = networkPathPublisher
  }
}


import Contacts

// RxContacts
//public func requestAccess(for entityType: CNEntityType) -> Observable<Bool> {
//    return Observable.create { observer in
//        self.base.requestAccess(for: entityType, completionHandler: { bool, error in
//            if let error = error {
//                observer.onError(error)
//            }
//            observer.onNext(bool)
//            observer.onCompleted()
//        })
//        return Disposables.create()
//    }
//}

// Combine
//public func requestAccess(for entityType: CNEntityType) -> AnyPublisher<Bool, Never> {
//    return Observable.create { observer in
//        self.base.requestAccess(for: entityType, completionHandler: { bool, error in
//            if let error = error {
//                observer.onError(error)
//            }
//            observer.onNext(bool)
//            observer.onCompleted()
//        })
//        return Disposables.create()
//    }
//}
