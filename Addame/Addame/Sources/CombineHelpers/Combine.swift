import Combine

extension Publisher where Output == Never {
  public func setOutputType<NewOutput>(to _: NewOutput.Type) -> AnyPublisher<NewOutput, Failure> {
    func absurd<A>(_: Never) -> A {}
    return map(absurd).eraseToAnyPublisher()
  }
}

extension Publisher {
  public func ignoreOutput<NewOutput>(
    setOutputType _: NewOutput.Type
  ) -> AnyPublisher<NewOutput, Failure> {
    return
      ignoreOutput()
      .setOutputType(to: NewOutput.self)
  }

  public func ignoreFailure<NewFailure>(
    setFailureType _: NewFailure.Type
  ) -> AnyPublisher<Output, NewFailure> {
    self
      .catch { _ in Empty() }
      .setFailureType(to: NewFailure.self)
      .eraseToAnyPublisher()
  }

  public func ignoreFailure() -> AnyPublisher<Output, Never> {
    self
      .catch { _ in Empty() }
      .setFailureType(to: Never.self)
      .eraseToAnyPublisher()
  }
}
