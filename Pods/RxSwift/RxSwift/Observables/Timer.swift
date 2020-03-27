//
//  Timer.swift
//  RxSwift
//
//

extension ObservableType where Element : RxAbstractInteger {
    
    public static func interval(_ period: RxTimeInterval, scheduler: SchedulerType)
        -> Observable<Element> {
        return Timer(
            dueTime: period,
            period: period,
            scheduler: scheduler
        )
    }
}

extension ObservableType where Element: RxAbstractInteger {
    
    public static func timer(_ dueTime: RxTimeInterval, period: RxTimeInterval? = nil, scheduler: SchedulerType)
        -> Observable<Element> {
        return Timer(
            dueTime: dueTime,
            period: period,
            scheduler: scheduler
        )
    }
}

import Foundation

final private class TimerSink<Observer: ObserverType> : Sink<Observer> where Observer.Element : RxAbstractInteger  {
    typealias Parent = Timer<Observer.Element>

    private let _parent: Parent
    private let _lock = RecursiveLock()

    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self._parent = parent
        super.init(observer: observer, cancel: cancel)
    }

    func run() -> Disposable {
        return self._parent._scheduler.schedulePeriodic(0 as Observer.Element, startAfter: self._parent._dueTime, period: self._parent._period!) { state in
            self._lock.lock(); defer { self._lock.unlock() }
            self.forwardOn(.next(state))
            return state &+ 1
        }
    }
}

final private class TimerOneOffSink<Observer: ObserverType>: Sink<Observer> where Observer.Element: RxAbstractInteger {
    typealias Parent = Timer<Observer.Element>

    private let _parent: Parent

    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self._parent = parent
        super.init(observer: observer, cancel: cancel)
    }

    func run() -> Disposable {
        return self._parent._scheduler.scheduleRelative(self, dueTime: self._parent._dueTime) { [unowned self] _ -> Disposable in
            self.forwardOn(.next(0))
            self.forwardOn(.completed)
            self.dispose()

            return Disposables.create()
        }
    }
}

final private class Timer<Element: RxAbstractInteger>: Producer<Element> {
    fileprivate let _scheduler: SchedulerType
    fileprivate let _dueTime: RxTimeInterval
    fileprivate let _period: RxTimeInterval?

    init(dueTime: RxTimeInterval, period: RxTimeInterval?, scheduler: SchedulerType) {
        self._scheduler = scheduler
        self._dueTime = dueTime
        self._period = period
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        if self._period != nil {
            let sink = TimerSink(parent: self, observer: observer, cancel: cancel)
            let subscription = sink.run()
            return (sink: sink, subscription: subscription)
        }
        else {
            let sink = TimerOneOffSink(parent: self, observer: observer, cancel: cancel)
            let subscription = sink.run()
            return (sink: sink, subscription: subscription)
        }
    }
}
