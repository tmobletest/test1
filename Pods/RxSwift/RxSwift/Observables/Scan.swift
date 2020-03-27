//
//  Scan.swift
//  RxSwift
//


extension ObservableType {

    
    public func scan<A>(into seed: A, accumulator: @escaping (inout A, Element) throws -> Void)
        -> Observable<A> {
        return Scan(source: self.asObservable(), seed: seed, accumulator: accumulator)
    }

    
    public func scan<A>(_ seed: A, accumulator: @escaping (A, Element) throws -> A)
        -> Observable<A> {
        return Scan(source: self.asObservable(), seed: seed) { acc, element in
            let currentAcc = acc
            acc = try accumulator(currentAcc, element)
        }
    }
}

final private class ScanSink<Element, Observer: ObserverType>: Sink<Observer>, ObserverType {
    typealias Accumulate = Observer.Element 
    typealias Parent = Scan<Element, Accumulate>

    fileprivate let _parent: Parent
    fileprivate var _accumulate: Accumulate
    
    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self._parent = parent
        self._accumulate = parent._seed
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: Event<Element>) {
        switch event {
        case .next(let element):
            do {
                try self._parent._accumulator(&self._accumulate, element)
                self.forwardOn(.next(self._accumulate))
            }
            catch let error {
                self.forwardOn(.error(error))
                self.dispose()
            }
        case .error(let error):
            self.forwardOn(.error(error))
            self.dispose()
        case .completed:
            self.forwardOn(.completed)
            self.dispose()
        }
    }
    
}

final private class Scan<Element, Accumulate>: Producer<Accumulate> {
    typealias Accumulator = (inout Accumulate, Element) throws -> Void
    
    fileprivate let _source: Observable<Element>
    fileprivate let _seed: Accumulate
    fileprivate let _accumulator: Accumulator
    
    init(source: Observable<Element>, seed: Accumulate, accumulator: @escaping Accumulator) {
        self._source = source
        self._seed = seed
        self._accumulator = accumulator
    }
    
    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Accumulate {
        let sink = ScanSink(parent: self, observer: observer, cancel: cancel)
        let subscription = self._source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
