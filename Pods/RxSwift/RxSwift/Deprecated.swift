//
//  Deprecated.swift
//  RxSwift
//
//

import Foundation

extension Observable {
    @available(*, deprecated, message: "Implicit conversions from any type to optional type are allowed and that is causing issues with `from` operator overloading.", renamed: "from(optional:)")
    public static func from(_ optional: Element?) -> Observable<Element> {
        return Observable.from(optional: optional)
    }

    
    @available(*, deprecated, message: "Implicit conversions from any type to optional type are allowed and that is causing issues with `from` operator overloading.", renamed: "from(optional:scheduler:)")
    public static func from(_ optional: Element?, scheduler: ImmediateSchedulerType) -> Observable<Element> {
        return Observable.from(optional: optional, scheduler: scheduler)
    }
}

extension ObservableType {
   
    @available(*, deprecated, message: "Please use enumerated().map()")
    public func mapWithIndex<Result>(_ selector: @escaping (Element, Int) throws -> Result)
        -> Observable<Result> {
        return self.enumerated().map { try selector($0.element, $0.index) }
    }


    
    @available(*, deprecated, message: "Please use enumerated().flatMap()")
    public func flatMapWithIndex<Source: ObservableConvertibleType>(_ selector: @escaping (Element, Int) throws -> Source)
        -> Observable<Source.Element> {
        return self.enumerated().flatMap { try selector($0.element, $0.index) }
    }

    
    @available(*, deprecated, message: "Please use enumerated().skipWhile().map()")
    public func skipWhileWithIndex(_ predicate: @escaping (Element, Int) throws -> Bool) -> Observable<Element> {
        return self.enumerated().skipWhile { try predicate($0.element, $0.index) }.map { $0.element }
    }


    
    @available(*, deprecated, message: "Please use enumerated().takeWhile().map()")
    public func takeWhileWithIndex(_ predicate: @escaping (Element, Int) throws -> Bool) -> Observable<Element> {
        return self.enumerated().takeWhile { try predicate($0.element, $0.index) }.map { $0.element }
    }
}

extension Disposable {
    /// Deprecated in favor of `disposed(by:)`
    ///
    ///
    /// Adds `self` to `bag`.
    ///
    /// - parameter bag: `DisposeBag` to add `self` to.
    @available(*, deprecated, message: "use disposed(by:) instead", renamed: "disposed(by:)")
    public func addDisposableTo(_ bag: DisposeBag) {
        self.disposed(by: bag)
    }
}


extension ObservableType {

    
    @available(*, deprecated, message: "use share(replay: 1) instead", renamed: "share(replay:)")
    public func shareReplayLatestWhileConnected()
        -> Observable<Element> {
        return self.share(replay: 1, scope: .whileConnected)
    }
}


extension ObservableType {

    
    @available(*, deprecated, message: "Suggested replacement is `share(replay: 1)`. In case old 3.x behavior of `shareReplay` is required please use `share(replay: 1, scope: .forever)` instead.", renamed: "share(replay:)")
    public func shareReplay(_ bufferSize: Int)
        -> Observable<Element> {
        return self.share(replay: bufferSize, scope: .forever)
    }
}

@available(*, deprecated, message: "Variable is deprecated. Please use `BehaviorRelay` as a replacement.")
public final class Variable<Element> {
    private let _subject: BehaviorSubject<Element>

    private var _lock = SpinLock()

    // state
    private var _value: Element

    #if DEBUG
    fileprivate let _synchronizationTracker = SynchronizationTracker()
    #endif

    
    public var value: Element {
        get {
            self._lock.lock(); defer { self._lock.unlock() }
            return self._value
        }
        set(newValue) {
            #if DEBUG
                self._synchronizationTracker.register(synchronizationErrorMessage: .variable)
                defer { self._synchronizationTracker.unregister() }
            #endif
            self._lock.lock()
            self._value = newValue
            self._lock.unlock()

            self._subject.on(.next(newValue))
        }
    }

    
    public init(_ value: Element) {
        self._value = value
        self._subject = BehaviorSubject(value: value)
    }

    
    }

    deinit {
        self._subject.on(.completed)
    }
}

extension ObservableType {
    
    @available(*, deprecated, message: "Use DispatchTimeInterval overload instead.", renamed: "delay(_:scheduler:)")
    public func delay(_ dueTime: Foundation.TimeInterval, scheduler: SchedulerType)
        -> Observable<Element> {
        return self.delay(.milliseconds(Int(dueTime * 1000.0)), scheduler: scheduler)
    }
}

extension ObservableType {
    
    
    @available(*, deprecated, message: "Use DispatchTimeInterval overload instead.", renamed: "timeout(_:scheduler:)")
    public func timeout(_ dueTime: Foundation.TimeInterval, scheduler: SchedulerType)
        -> Observable<Element> {
        return timeout(.milliseconds(Int(dueTime * 1000.0)), scheduler: scheduler)
    }
    
    @available(*, deprecated, message: "Use DispatchTimeInterval overload instead.", renamed: "timeout(_:other:scheduler:)")
    public func timeout<OtherSource: ObservableConvertibleType>(_ dueTime: Foundation.TimeInterval, other: OtherSource, scheduler: SchedulerType)
        -> Observable<Element> where Element == OtherSource.Element {
        return timeout(.milliseconds(Int(dueTime * 1000.0)), other: other, scheduler: scheduler)
    }
}

extension ObservableType {
    
   
    @available(*, deprecated, message: "Use DispatchTimeInterval overload instead.", renamed: "skip(_:scheduler:)")
    public func skip(_ duration: Foundation.TimeInterval, scheduler: SchedulerType)
        -> Observable<Element> {
        return skip(.milliseconds(Int(duration * 1000.0)), scheduler: scheduler)
    }
}

extension ObservableType where Element : RxAbstractInteger {
    
    @available(*, deprecated, message: "Use DispatchTimeInterval overload instead.", renamed: "interval(_:scheduler:)")
    public static func interval(_ period: Foundation.TimeInterval, scheduler: SchedulerType)
        -> Observable<Element> {
        return interval(.milliseconds(Int(period * 1000.0)), scheduler: scheduler)
    }
}

extension ObservableType where Element: RxAbstractInteger {
    
    @available(*, deprecated, message: "Use DispatchTimeInterval overload instead.", renamed: "timer(_:period:scheduler:)")
    public static func timer(_ dueTime: Foundation.TimeInterval, period: Foundation.TimeInterval? = nil, scheduler: SchedulerType)
        -> Observable<Element> {
        return timer(.milliseconds(Int(dueTime * 1000.0)), period: period.map { .milliseconds(Int($0 * 1000.0)) }, scheduler: scheduler)
    }
}

extension ObservableType {
    
    
    @available(*, deprecated, message: "Use DispatchTimeInterval overload instead.", renamed: "throttle(_:latest:scheduler:)")
    public func throttle(_ dueTime: Foundation.TimeInterval, latest: Bool = true, scheduler: SchedulerType)
        -> Observable<Element> {
        return throttle(.milliseconds(Int(dueTime * 1000.0)), latest: latest, scheduler: scheduler)
    }
}

extension ObservableType {
    
   
    @available(*, deprecated, message: "Use DispatchTimeInterval overload instead.", renamed: "take(_:scheduler:)")
    public func take(_ duration: Foundation.TimeInterval, scheduler: SchedulerType)
        -> Observable<Element> {
        return take(.milliseconds(Int(duration * 1000.0)), scheduler: scheduler)
    }
}


extension ObservableType {
    
    
    @available(*, deprecated, message: "Use DispatchTimeInterval overload instead.", renamed: "delaySubscription(_:scheduler:)")
    public func delaySubscription(_ dueTime: Foundation.TimeInterval, scheduler: SchedulerType)
        -> Observable<Element> {
        return delaySubscription(.milliseconds(Int(dueTime * 1000.0)), scheduler: scheduler)
    }
}

extension ObservableType {
    
    
    @available(*, deprecated, message: "Use DispatchTimeInterval overload instead.", renamed: "window(_:)")
    public func window(timeSpan: Foundation.TimeInterval, count: Int, scheduler: SchedulerType)
        -> Observable<Observable<Element>> {
            return window(timeSpan: .milliseconds(Int(timeSpan * 1000.0)), count: count, scheduler: scheduler)
    }
}


extension PrimitiveSequence {
    
    @available(*, deprecated, message: "Use DispatchTimeInterval overload instead.", renamed: "delay(_:scheduler:)")
    public func delay(_ dueTime: Foundation.TimeInterval, scheduler: SchedulerType)
        -> PrimitiveSequence<Trait, Element> {
        return delay(.milliseconds(Int(dueTime * 1000.0)), scheduler: scheduler)
    }
            
    @available(*, deprecated, message: "Use DispatchTimeInterval overload instead.", renamed: "delaySubscription(_:scheduler:)")
    public func delaySubscription(_ dueTime: Foundation.TimeInterval, scheduler: SchedulerType)
        -> PrimitiveSequence<Trait, Element> {
        return delaySubscription(.milliseconds(Int(dueTime * 1000.0)), scheduler: scheduler)
    }
    
    
    @available(*, deprecated, message: "Use DispatchTimeInterval overload instead.", renamed: "timeout(_:scheduler:)")
    public func timeout(_ dueTime: Foundation.TimeInterval, scheduler: SchedulerType)
        -> PrimitiveSequence<Trait, Element> {
        return timeout(.milliseconds(Int(dueTime * 1000.0)), scheduler: scheduler)
    }
    
    
    @available(*, deprecated, message: "Use DispatchTimeInterval overload instead.", renamed: "timeout(_:other:scheduler:)")
    public func timeout(_ dueTime: Foundation.TimeInterval,
                        other: PrimitiveSequence<Trait, Element>,
                        scheduler: SchedulerType) -> PrimitiveSequence<Trait, Element> {
        return timeout(.milliseconds(Int(dueTime * 1000.0)), other: other, scheduler: scheduler)
    }
}

extension PrimitiveSequenceType where Trait == SingleTrait {

 
    @available(*, deprecated, renamed: "do(onSuccess:onError:onSubscribe:onSubscribed:onDispose:)")
    public func `do`(onNext: ((Element) throws -> Void)?,
                     onError: ((Swift.Error) throws -> Void)? = nil,
                     onSubscribe: (() -> Void)? = nil,
                     onSubscribed: (() -> Void)? = nil,
                     onDispose: (() -> Void)? = nil)
        -> Single<Element> {
        return self.`do`(
            onSuccess: onNext,
            onError: onError,
            onSubscribe: onSubscribe,
            onSubscribed: onSubscribed,
            onDispose: onDispose
        )
    }
}

extension ObservableType {
    @available(*, deprecated, message: "Use DispatchTimeInterval overload instead.", renamed: "buffer(timeSpan:count:scheduler:)")
    public func buffer(timeSpan: Foundation.TimeInterval, count: Int, scheduler: SchedulerType)
        -> Observable<[Element]> {
        return buffer(timeSpan: .milliseconds(Int(timeSpan * 1000.0)), count: count, scheduler: scheduler)
    }
}

extension PrimitiveSequenceType where Element: RxAbstractInteger
{
    
    @available(*, deprecated, message: "Use DispatchTimeInterval overload instead.", renamed: "timer(_:scheduler:)")
    public static func timer(_ dueTime: Foundation.TimeInterval, scheduler: SchedulerType)
        -> PrimitiveSequence<Trait, Element>  {
        return timer(.milliseconds(Int(dueTime * 1000.0)), scheduler: scheduler)
    }
}

extension Completable {
    
    @available(*, deprecated, message: "Use Completable.zip instead.", renamed: "zip")
    public static func merge<Collection: Swift.Collection>(_ sources: Collection) -> Completable
           where Collection.Element == Completable {
        return zip(sources)
    }

    
    @available(*, deprecated, message: "Use Completable.zip instead.", renamed: "zip")
    public static func merge(_ sources: [Completable]) -> Completable {
        return zip(sources)
    }

    
    @available(*, deprecated, message: "Use Completable.zip instead.", renamed: "zip")
    public static func merge(_ sources: Completable...) -> Completable {
        return zip(sources)
    }
}
