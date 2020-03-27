//
//  PrimitiveSequence.swift
//  RxSwift
//
//

/// Observable sequences containing 0 or 1 element.
public struct PrimitiveSequence<Trait, Element> {
    let source: Observable<Element>

    init(raw: Observable<Element>) {
        self.source = raw
    }
}

/// Observable sequences containing 0 or 1 element
public protocol PrimitiveSequenceType {
    /// Additional constraints
    associatedtype Trait

    /// Sequence element type
    associatedtype Element

    @available(*, deprecated, message: "Use `Trait` instead.")
    typealias TraitType = Trait

    @available(*, deprecated, message: "Use `Element` instead.")
    typealias ElementType = Element

    // Converts `self` to primitive sequence.
    ///
    /// - returns: Observable sequence that represents `self`.
    var primitiveSequence: PrimitiveSequence<Trait, Element> { get }
}

extension PrimitiveSequence: PrimitiveSequenceType {
    // Converts `self` to primitive sequence.
    ///
    /// - returns: Observable sequence that represents `self`.
    public var primitiveSequence: PrimitiveSequence<Trait, Element> {
        return self
    }
}

extension PrimitiveSequence: ObservableConvertibleType {
    /// Converts `self` to `Observable` sequence.
    ///
    /// - returns: Observable sequence that represents `self`.
    public func asObservable() -> Observable<Element> {
        return self.source
    }
}

extension PrimitiveSequence {
    /**
     Returns an observable sequence that invokes the specified factory function whenever a new observer subscribes.

     - seealso: [defer operator on reactivex.io](http://reactivex.io/documentation/operators/defer.html)

     - parameter observableFactory: Observable factory function to invoke for each observer that subscribes to the resulting sequence.
     - returns: An observable sequence whose observers trigger an invocation of the given observable factory function.
     */
    public static func deferred(_ observableFactory: @escaping () throws -> PrimitiveSequence<Trait, Element>)
        -> PrimitiveSequence<Trait, Element> {
        return PrimitiveSequence(raw: Observable.deferred {
            try observableFactory().asObservable()
        })
    }

    public func delay(_ dueTime: RxTimeInterval, scheduler: SchedulerType)
        -> PrimitiveSequence<Trait, Element> {
        return PrimitiveSequence(raw: self.primitiveSequence.source.delay(dueTime, scheduler: scheduler))
    }

    
    public func delaySubscription(_ dueTime: RxTimeInterval, scheduler: SchedulerType)
        -> PrimitiveSequence<Trait, Element> {
        return PrimitiveSequence(raw: self.source.delaySubscription(dueTime, scheduler: scheduler))
    }
    
    
    public func observeOn(_ scheduler: ImmediateSchedulerType)
        -> PrimitiveSequence<Trait, Element> {
        return PrimitiveSequence(raw: self.source.observeOn(scheduler))
    }

    
    public func subscribeOn(_ scheduler: ImmediateSchedulerType)
        -> PrimitiveSequence<Trait, Element> {
        return PrimitiveSequence(raw: self.source.subscribeOn(scheduler))
    }

    
    public func catchError(_ handler: @escaping (Swift.Error) throws -> PrimitiveSequence<Trait, Element>)
        -> PrimitiveSequence<Trait, Element> {
        return PrimitiveSequence(raw: self.source.catchError { try handler($0).asObservable() })
    }

  
    public func retry(_ maxAttemptCount: Int)
        -> PrimitiveSequence<Trait, Element> {
        return PrimitiveSequence(raw: self.source.retry(maxAttemptCount))
    }

    
    public func retryWhen<TriggerObservable: ObservableType, Error: Swift.Error>(_ notificationHandler: @escaping (Observable<Error>) -> TriggerObservable)
        -> PrimitiveSequence<Trait, Element> {
        return PrimitiveSequence(raw: self.source.retryWhen(notificationHandler))
    }

    
    public func retryWhen<TriggerObservable: ObservableType>(_ notificationHandler: @escaping (Observable<Swift.Error>) -> TriggerObservable)
        -> PrimitiveSequence<Trait, Element> {
        return PrimitiveSequence(raw: self.source.retryWhen(notificationHandler))
    }

    
    public func debug(_ identifier: String? = nil, trimOutput: Bool = false, file: String = #file, line: UInt = #line, function: String = #function)
        -> PrimitiveSequence<Trait, Element> {
            return PrimitiveSequence(raw: self.source.debug(identifier, trimOutput: trimOutput, file: file, line: line, function: function))
    }
    
    
    public static func using<Resource: Disposable>(_ resourceFactory: @escaping () throws -> Resource, primitiveSequenceFactory: @escaping (Resource) throws -> PrimitiveSequence<Trait, Element>)
        -> PrimitiveSequence<Trait, Element> {
            return PrimitiveSequence(raw: Observable.using(resourceFactory, observableFactory: { (resource: Resource) throws -> Observable<Element> in
                return try primitiveSequenceFactory(resource).asObservable()
            }))
    }

   
    public func timeout(_ dueTime: RxTimeInterval, scheduler: SchedulerType)
        -> PrimitiveSequence<Trait, Element> {
            return PrimitiveSequence<Trait, Element>(raw: self.primitiveSequence.source.timeout(dueTime, scheduler: scheduler))
    }
    
    
    public func timeout(_ dueTime: RxTimeInterval,
                        other: PrimitiveSequence<Trait, Element>,
                        scheduler: SchedulerType) -> PrimitiveSequence<Trait, Element> {
        return PrimitiveSequence<Trait, Element>(raw: self.primitiveSequence.source.timeout(dueTime, other: other.source, scheduler: scheduler))
    }
}

extension PrimitiveSequenceType where Element: RxAbstractInteger
{
    
    public static func timer(_ dueTime: RxTimeInterval, scheduler: SchedulerType)
        -> PrimitiveSequence<Trait, Element>  {
        return PrimitiveSequence(raw: Observable<Element>.timer(dueTime, scheduler: scheduler))
    }
}
