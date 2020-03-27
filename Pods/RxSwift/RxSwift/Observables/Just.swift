//
//  Just.swift
//  RxSwift
//
//

extension ObservableType {
    
    public static func just(_ element: Element, scheduler: ImmediateSchedulerType) -> Observable<Element> {
        return JustScheduled(element: element, scheduler: scheduler)
    }
}

final private class JustScheduledSink<Observer: ObserverType>: Sink<Observer> {
    typealias Parent = JustScheduled<Observer.Element>

    private let _parent: Parent

    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self._parent = parent
        super.init(observer: observer, cancel: cancel)
    }

    func run() -> Disposable {
        let scheduler = self._parent._scheduler
        return scheduler.schedule(self._parent._element) { element in
            self.forwardOn(.next(element))
            return scheduler.schedule(()) { _ in
                self.forwardOn(.completed)
                self.dispose()
                return Disposables.create()
            }
        }
    }
}

final private class JustScheduled<Element>: Producer<Element> {
    fileprivate let _scheduler: ImmediateSchedulerType
    fileprivate let _element: Element

    init(element: Element, scheduler: ImmediateSchedulerType) {
        self._scheduler = scheduler
        self._element = element
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = JustScheduledSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}

final private class Just<Element>: Producer<Element> {
    private let _element: Element
    
    init(element: Element) {
        self._element = element
    }
    
    override func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        observer.on(.next(self._element))
        observer.on(.completed)
        return Disposables.create()
    }
}
