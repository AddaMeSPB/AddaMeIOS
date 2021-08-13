//
//  FlatMapLatest.swift
//  
//
//  Created by Saroar Khandoker on 05.04.2021.
//

import Combine

extension Publisher {
    public func flatMapLatest<U>(
        _ transformation: @escaping (Self.Output) -> U
    ) -> Publishers.FlatMapLatest<Self, U>
        where U: Publisher, U.Failure == Self.Failure {
        return Publishers.FlatMapLatest(upstream: self, transform: transformation)
    }
}

extension Publishers {
    public struct FlatMapLatest<Upstream, P>: Publisher
        where P: Publisher, Upstream: Publisher, P.Failure == Upstream.Failure {

        // swiftlint:disable:next nesting
        public typealias Output = P.Output
        public typealias Failure = Upstream.Failure
        // swiftlint:disable:previous nesting

        private let upstream: Upstream
        private let transform: (Upstream.Output) -> P

        init(upstream: Upstream, transform: @escaping (Upstream.Output) -> P) {
            self.upstream = upstream
            self.transform = transform
        }

        public func receive<S>(subscriber: S) where S: Subscriber, P.Output == S.Input, Upstream.Failure == S.Failure {
            self.upstream.map(self.transform)
                .switchToLatest()
                .receive(subscriber: subscriber)
        }
    }
}
