//
//  Materialize.swift
//  RxSwift
//


extension ObservableType {
   
    public func materialize() -> Observable<Event<Element>> {
        return Materialize(source: self.asObservable())
    }
}

fileprivate final class MaterializeSink<Element, Observer: ObserverType>: Sink<Observer>, ObserverType where Observer.Element == Event<Element> {

    func on(_ event: Event<Element>) {
        self.forwardOn(.next(event))
        if event.isStopEvent {
            self.forwardOn(.completed)
            self.dispose()
        }
    }
}

final private class Materialize<T>: Producer<Event<T>> {
    private let _source: Observable<T>

    init(source: Observable<T>) {
        self._source = source
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = MaterializeSink(observer: observer, cancel: cancel)
        let subscription = self._source.subscribe(sink)

        return (sink: sink, subscription: subscription)
    }
}
