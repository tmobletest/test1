//
//  Generate.swift
//  RxSwift
//
//

extension ObservableType {
   
    public static func generate(initialState: Element, condition: @escaping (Element) throws -> Bool, scheduler: ImmediateSchedulerType = CurrentThreadScheduler.instance, iterate: @escaping (Element) throws -> Element) -> Observable<Element> {
        return Generate(initialState: initialState, condition: condition, iterate: iterate, resultSelector: { $0 }, scheduler: scheduler)
    }
}

final private class GenerateSink<Sequence, Observer: ObserverType>: Sink<Observer> {
    typealias Parent = Generate<Sequence, Observer.Element>
    
    private let _parent: Parent
    
    private var _state: Sequence
    
    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self._parent = parent
        self._state = parent._initialState
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        return self._parent._scheduler.scheduleRecursive(true) { isFirst, recurse -> Void in
            do {
                if !isFirst {
                    self._state = try self._parent._iterate(self._state)
                }
                
                if try self._parent._condition(self._state) {
                    let result = try self._parent._resultSelector(self._state)
                    self.forwardOn(.next(result))
                    
                    recurse(false)
                }
                else {
                    self.forwardOn(.completed)
                    self.dispose()
                }
            }
            catch let error {
                self.forwardOn(.error(error))
                self.dispose()
            }
        }
    }
}

final private class Generate<Sequence, Element>: Producer<Element> {
    fileprivate let _initialState: Sequence
    fileprivate let _condition: (Sequence) throws -> Bool
    fileprivate let _iterate: (Sequence) throws -> Sequence
    fileprivate let _resultSelector: (Sequence) throws -> Element
    fileprivate let _scheduler: ImmediateSchedulerType
    
    init(initialState: Sequence, condition: @escaping (Sequence) throws -> Bool, iterate: @escaping (Sequence) throws -> Sequence, resultSelector: @escaping (Sequence) throws -> Element, scheduler: ImmediateSchedulerType) {
        self._initialState = initialState
        self._condition = condition
        self._iterate = iterate
        self._resultSelector = resultSelector
        self._scheduler = scheduler
        super.init()
    }
    
    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = GenerateSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
