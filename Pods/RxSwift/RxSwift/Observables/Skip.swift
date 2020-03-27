//
//  Skip.swift
//  RxSwift
//
//

extension ObservableType {

    public func skip(_ count: Int)
        -> Observable<Element> {
        return SkipCount(source: self.asObservable(), count: count)
    }
}

extension ObservableType {

    public func skip(_ duration: RxTimeInterval, scheduler: SchedulerType)
        -> Observable<Element> {
        return SkipTime(source: self.asObservable(), duration: duration, scheduler: scheduler)
    }
}

// count version

final private class SkipCountSink<Observer: ObserverType>: Sink<Observer>, ObserverType {
    typealias Element = Observer.Element 
    typealias Parent = SkipCount<Element>
    
    let parent: Parent
    
    var remaining: Int
    
    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self.parent = parent
        self.remaining = parent.count
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: Event<Element>) {
        switch event {
        case .next(let value):
            
            if self.remaining <= 0 {
                self.forwardOn(.next(value))
            }
            else {
                self.remaining -= 1
            }
        case .error:
            self.forwardOn(event)
            self.dispose()
        case .completed:
            self.forwardOn(event)
            self.dispose()
        }
    }
    
}

final private class SkipCount<Element>: Producer<Element> {
    let source: Observable<Element>
    let count: Int
    
    init(source: Observable<Element>, count: Int) {
        self.source = source
        self.count = count
    }
    
    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = SkipCountSink(parent: self, observer: observer, cancel: cancel)
        let subscription = self.source.subscribe(sink)

        return (sink: sink, subscription: subscription)
    }
}

// time version

final private class SkipTimeSink<Element, Observer: ObserverType>: Sink<Observer>, ObserverType where Observer.Element == Element {
    typealias Parent = SkipTime<Element>

    let parent: Parent
    
    // state
    var open = false
    
    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: Event<Element>) {
        switch event {
        case .next(let value):
            if self.open {
                self.forwardOn(.next(value))
            }
        case .error:
            self.forwardOn(event)
            self.dispose()
        case .completed:
            self.forwardOn(event)
            self.dispose()
        }
    }
    
    func tick() {
        self.open = true
    }
    
    func run() -> Disposable {
        let disposeTimer = self.parent.scheduler.scheduleRelative((), dueTime: self.parent.duration) { _ in 
            self.tick()
            return Disposables.create()
        }
        
        let disposeSubscription = self.parent.source.subscribe(self)
        
        return Disposables.create(disposeTimer, disposeSubscription)
    }
}

final private class SkipTime<Element>: Producer<Element> {
    let source: Observable<Element>
    let duration: RxTimeInterval
    let scheduler: SchedulerType
    
    init(source: Observable<Element>, duration: RxTimeInterval, scheduler: SchedulerType) {
        self.source = source
        self.scheduler = scheduler
        self.duration = duration
    }
    
    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = SkipTimeSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
