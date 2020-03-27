//
//  Optional.swift
//  RxSwift
//


extension ObservableType {
    
    public static func from(optional: Element?) -> Observable<Element> {
        return ObservableOptional(optional: optional)
    }

    
    public static func from(optional: Element?, scheduler: ImmediateSchedulerType) -> Observable<Element> {
        return ObservableOptionalScheduled(optional: optional, scheduler: scheduler)
    }
}

final private class ObservableOptionalScheduledSink<Observer: ObserverType>: Sink<Observer> {
    typealias Element = Observer.Element 
    typealias Parent = ObservableOptionalScheduled<Element>

    private let _parent: Parent

    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self._parent = parent
        super.init(observer: observer, cancel: cancel)
    }

    func run() -> Disposable {
        return self._parent._scheduler.schedule(self._parent._optional) { (optional: Element?) -> Disposable in
            if let next = optional {
                self.forwardOn(.next(next))
                return self._parent._scheduler.schedule(()) { _ in
                    self.forwardOn(.completed)
                    self.dispose()
                    return Disposables.create()
                }
            } else {
                self.forwardOn(.completed)
                self.dispose()
                return Disposables.create()
            }
        }
    }
}

final private class ObservableOptionalScheduled<Element>: Producer<Element> {
    fileprivate let _optional: Element?
    fileprivate let _scheduler: ImmediateSchedulerType

    init(optional: Element?, scheduler: ImmediateSchedulerType) {
        self._optional = optional
        self._scheduler = scheduler
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = ObservableOptionalScheduledSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}

final private class ObservableOptional<Element>: Producer<Element> {
    private let _optional: Element?
    
    init(optional: Element?) {
        self._optional = optional
    }
    
    override func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        if let element = self._optional {
            observer.on(.next(element))
        }
        observer.on(.completed)
        return Disposables.create()
    }
}
