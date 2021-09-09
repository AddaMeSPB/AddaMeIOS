import Combine
import Foundation

// Adapted from https://www.onswiftwings.com/posts/share-replay-operator/
public final class ReplaySubject<Output, Failure: Error>: Subject {
  private var buffer = [Output]()
  private let bufferSize: Int
  private var subscriptions = [Subscription<Output, Failure>]()
  private var completion: Subscribers.Completion<Failure>?
  private let lock = NSRecursiveLock()

  public init(_ bufferSize: Int = 0) {
    self.bufferSize = bufferSize
  }

  public func send(subscription: Combine.Subscription) {
    lock.lock()
    defer { self.lock.unlock() }
    subscription.request(.unlimited)
  }

  public func send(_ value: Output) {
    lock.lock()
    defer { self.lock.unlock() }
    buffer.append(value)
    buffer = buffer.suffix(bufferSize)
    subscriptions.forEach { $0.receive(value) }
  }

  public func send(completion: Subscribers.Completion<Failure>) {
    lock.lock()
    defer { self.lock.unlock() }
    self.completion = completion
    subscriptions.forEach { $0.receive(completion: completion) }
  }

  public func receive<Downstream: Subscriber>(subscriber: Downstream)
  where Downstream.Failure == Failure, Downstream.Input == Output {
    lock.lock()
    defer { self.lock.unlock() }
    let subscription = Subscription(downstream: AnySubscriber(subscriber))
    subscriber.receive(subscription: subscription)
    subscriptions.append(subscription)
    subscription.replay(buffer, completion: completion)
  }

  private final class Subscription<Output, Failure: Error>: Combine.Subscription {
    private let downstream: AnySubscriber<Output, Failure>
    private var isCompleted = false
    private var demand: Subscribers.Demand = .none

    init(downstream: AnySubscriber<Output, Failure>) {
      self.downstream = downstream
    }

    func request(_ newDemand: Subscribers.Demand) {
      demand += newDemand
    }

    func cancel() {
      isCompleted = true
    }

    public func receive(_ value: Output) {
      guard !isCompleted, demand > 0 else { return }
      demand += downstream.receive(value)
      demand -= 1
    }

    public func receive(completion: Subscribers.Completion<Failure>) {
      guard !isCompleted else { return }
      isCompleted = true
      downstream.receive(completion: completion)
    }

    public func replay(_ values: [Output], completion: Subscribers.Completion<Failure>?) {
      guard !isCompleted else { return }
      values.forEach { value in self.receive(value) }
      if let completion = completion { receive(completion: completion) }
    }
  }
}

extension Publisher {
  public func shareReplay(
    _ bufferSize: Int
  )
    -> Publishers.Autoconnect<Publishers.Multicast<Self, ReplaySubject<Output, Failure>>> {
    multicast(subject: ReplaySubject(bufferSize))
      .autoconnect()
  }
}
