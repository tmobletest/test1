//
//  Timeout.swift
//  RxSwift
//


extension ObservableType {

    
    public func timeout(_ dueTime: RxTimeInterval, scheduler: SchedulerType)
        -> Observable<Element> {
            return Timeout(source: self.asObservable(), dueTime: dueTime, other: Observable.error(RxError.timeout), scheduler: scheduler)
    }

    public func timeout<Source: ObservableConvertibleType>(_ dueTime: RxTimeInterval, other: Source, scheduler: SchedulerType)
        -> Observable<Element> where Element == Source.Element {
            return Timeout(source: self.asObservable(), dueTime: dueTime, other: other.asObservable(), scheduler: scheduler)
    }
}

final private class TimeoutSink<Observer: ObserverType>: Sink<Observer>, LockOwnerType, ObserverType {
    typealias Element = Observer.Element 
    typealias Parent = Timeout<Element>
    
    private let _parent: Parent
    
    let _lock = RecursiveLock()

    private let _timerD = SerialDisposable()
    private let _subscription = SerialDisposable()
    
    private var _id = 0
    private var _switched = false
    
    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self._parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        let original = SingleAssignmentDisposable()
        self._subscription.disposable = original
        
        self._createTimeoutTimer()
        
        original.setDisposable(self._parent._source.subscribe(self))
        
        return Disposables.create(_subscription, _timerD)
    }

    func on(_ event: Event<Element>) {
        switch event {
        case .next:
            var onNextWins = false
            
            self._lock.performLocked {
                onNextWins = !self._switched
                if onNextWins {
                    self._id = self._id &+ 1
                }
            }
            
            if onNextWins {
                self.forwardOn(event)
                self._createTimeoutTimer()
            }
        case .error, .completed:
            var onEventWins = false
            
            self._lock.performLocked {
                onEventWins = !self._switched
                if onEventWins {
                    self._id = self._id &+ 1
                }
            }
            
            if onEventWins {
                self.forwardOn(event)
                self.dispose()
            }
        }
    }
    
    private func _createTimeoutTimer() {
        if self._timerD.isDisposed {
            return
        }
        
        let nextTimer = SingleAssignmentDisposable()
        self._timerD.disposable = nextTimer
        
        let disposeSchedule = self._parent._scheduler.scheduleRelative(self._id, dueTime: self._parent._dueTime) { state in
            
            var timerWins = false
            
            self._lock.performLocked {
                self._switched = (state == self._id)
                timerWins = self._switched
            }
            
            if timerWins {
                self._subscription.disposable = self._parent._other.subscribe(self.forwarder())
            }
            
            return Disposables.create()
        }

        nextTimer.setDisposable(disposeSchedule)
    }
}


final private class Timeout<Element>: Producer<Element> {
    fileprivate let _source: Observable<Element>
    fileprivate let _dueTime: RxTimeInterval
    fileprivate let _other: Observable<Element>
    fileprivate let _scheduler: SchedulerType
    
    init(source: Observable<Element>, dueTime: RxTimeInterval, other: Observable<Element>, scheduler: SchedulerType) {
        self._source = source
        self._dueTime = dueTime
        self._other = other
        self._scheduler = scheduler
    }
    
    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = TimeoutSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
