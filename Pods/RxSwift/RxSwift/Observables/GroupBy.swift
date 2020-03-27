//
//  GroupBy.swift
//  RxSwift
//


extension ObservableType {
  
    public func groupBy<Key: Hashable>(keySelector: @escaping (Element) throws -> Key)
        -> Observable<GroupedObservable<Key, Element>> {
        return GroupBy(source: self.asObservable(), selector: keySelector)
    }
}

final private class GroupedObservableImpl<Element>: Observable<Element> {
    private var _subject: PublishSubject<Element>
    private var _refCount: RefCountDisposable
    
    init(subject: PublishSubject<Element>, refCount: RefCountDisposable) {
        self._subject = subject
        self._refCount = refCount
    }

    override public func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        let release = self._refCount.retain()
        let subscription = self._subject.subscribe(observer)
        return Disposables.create(release, subscription)
    }
}


final private class GroupBySink<Key: Hashable, Element, Observer: ObserverType>
    : Sink<Observer>
    , ObserverType where Observer.Element == GroupedObservable<Key, Element> {
    typealias ResultType = Observer.Element 
    typealias Parent = GroupBy<Key, Element>

    private let _parent: Parent
    private let _subscription = SingleAssignmentDisposable()
    private var _refCountDisposable: RefCountDisposable!
    private var _groupedSubjectTable: [Key: PublishSubject<Element>]
    
    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self._parent = parent
        self._groupedSubjectTable = [Key: PublishSubject<Element>]()
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        self._refCountDisposable = RefCountDisposable(disposable: self._subscription)
        
        self._subscription.setDisposable(self._parent._source.subscribe(self))
        
        return self._refCountDisposable
    }
    
    private func onGroupEvent(key: Key, value: Element) {
        if let writer = self._groupedSubjectTable[key] {
            writer.on(.next(value))
        } else {
            let writer = PublishSubject<Element>()
            self._groupedSubjectTable[key] = writer
            
            let group = GroupedObservable(
                key: key,
                source: GroupedObservableImpl(subject: writer, refCount: _refCountDisposable)
            )
            
            self.forwardOn(.next(group))
            writer.on(.next(value))
        }
    }

    final func on(_ event: Event<Element>) {
        switch event {
        case let .next(value):
            do {
                let groupKey = try self._parent._selector(value)
                self.onGroupEvent(key: groupKey, value: value)
            }
            catch let e {
                self.error(e)
                return
            }
        case let .error(e):
            self.error(e)
        case .completed:
            self.forwardOnGroups(event: .completed)
            self.forwardOn(.completed)
            self._subscription.dispose()
            self.dispose()
        }
    }

    final func error(_ error: Swift.Error) {
        self.forwardOnGroups(event: .error(error))
        self.forwardOn(.error(error))
        self._subscription.dispose()
        self.dispose()
    }
    
    final func forwardOnGroups(event: Event<Element>) {
        for writer in self._groupedSubjectTable.values {
            writer.on(event)
        }
    }
}

final private class GroupBy<Key: Hashable, Element>: Producer<GroupedObservable<Key,Element>> {
    typealias KeySelector = (Element) throws -> Key

    fileprivate let _source: Observable<Element>
    fileprivate let _selector: KeySelector
    
    init(source: Observable<Element>, selector: @escaping KeySelector) {
        self._source = source
        self._selector = selector
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == GroupedObservable<Key,Element> {
        let sink = GroupBySink(parent: self, observer: observer, cancel: cancel)
        return (sink: sink, subscription: sink.run())
    }
}
