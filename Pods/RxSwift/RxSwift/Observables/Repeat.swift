//
//  Repeat.swift
//  RxSwift
//
//

extension ObservableType {
    
    public static func repeatElement(_ element: Element, scheduler: ImmediateSchedulerType = CurrentThreadScheduler.instance) -> Observable<Element> {
        return RepeatElement(element: element, scheduler: scheduler)
    }
}

final private class RepeatElement<Element>: Producer<Element> {
    fileprivate let _element: Element
    fileprivate let _scheduler: ImmediateSchedulerType
    
    init(element: Element, scheduler: ImmediateSchedulerType) {
        self._element = element
        self._scheduler = scheduler
    }
    
    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = RepeatElementSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()

        return (sink: sink, subscription: subscription)
    }
}

final private class RepeatElementSink<Observer: ObserverType>: Sink<Observer> {
    typealias Parent = RepeatElement<Observer.Element>
    
    private let _parent: Parent
    
    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self._parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        return self._parent._scheduler.scheduleRecursive(self._parent._element) { e, recurse in
            self.forwardOn(.next(e))
            recurse(e)
        }
    }
}
