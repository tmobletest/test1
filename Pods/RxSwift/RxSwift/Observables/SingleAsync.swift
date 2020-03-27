//
//  SingleAsync.swift
//  RxSwift
//
//

extension ObservableType {

    public func single()
        -> Observable<Element> {
        return SingleAsync(source: self.asObservable())
    }

    
    public func single(_ predicate: @escaping (Element) throws -> Bool)
        -> Observable<Element> {
        return SingleAsync(source: self.asObservable(), predicate: predicate)
    }
}

fileprivate final class SingleAsyncSink<Observer: ObserverType> : Sink<Observer>, ObserverType {
    typealias Element = Observer.Element
    typealias Parent = SingleAsync<Element>
    
    private let _parent: Parent
    private var _seenValue: Bool = false
    
    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self._parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: Event<Element>) {
        switch event {
        case .next(let value):
            do {
                let forward = try self._parent._predicate?(value) ?? true
                if !forward {
                    return
                }
            }
            catch let error {
                self.forwardOn(.error(error as Swift.Error))
                self.dispose()
                return
            }

            if self._seenValue {
                self.forwardOn(.error(RxError.moreThanOneElement))
                self.dispose()
                return
            }

            self._seenValue = true
            self.forwardOn(.next(value))
        case .error:
            self.forwardOn(event)
            self.dispose()
        case .completed:
            if self._seenValue {
                self.forwardOn(.completed)
            } else {
                self.forwardOn(.error(RxError.noElements))
            }
            self.dispose()
        }
    }
}

final class SingleAsync<Element>: Producer<Element> {
    typealias Predicate = (Element) throws -> Bool
    
    fileprivate let _source: Observable<Element>
    fileprivate let _predicate: Predicate?
    
    init(source: Observable<Element>, predicate: Predicate? = nil) {
        self._source = source
        self._predicate = predicate
    }
    
    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = SingleAsyncSink(parent: self, observer: observer, cancel: cancel)
        let subscription = self._source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
