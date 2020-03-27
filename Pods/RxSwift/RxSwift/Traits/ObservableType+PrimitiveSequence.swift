//
//  ObservableType+PrimitiveSequence.swift
//  RxSwift
//
//

extension ObservableType {
    
    public func asSingle() -> Single<Element> {
        return PrimitiveSequence(raw: AsSingle(source: self.asObservable()))
    }
    
    
    public func first() -> Single<Element?> {
        return PrimitiveSequence(raw: First(source: self.asObservable()))
    }

    
    public func asMaybe() -> Maybe<Element> {
        return PrimitiveSequence(raw: AsMaybe(source: self.asObservable()))
    }
}

extension ObservableType where Element == Never {
    /**
     - returns: An observable sequence that completes.
     */
    public func asCompletable()
        -> Completable {
            return PrimitiveSequence(raw: self.asObservable())
    }
}
