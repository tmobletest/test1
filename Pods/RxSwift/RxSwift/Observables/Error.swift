//
//  Error.swift
//  RxSwift
//
//

extension ObservableType {
    /**
     Returns an observable sequence that terminates with an `error`.

     - seealso: [throw operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

     - returns: The observable sequence that terminates with specified error.
     */
    public static func error(_ error: Swift.Error) -> Observable<Element> {
        return ErrorProducer(error: error)
    }
}

final private class ErrorProducer<Element>: Producer<Element> {
    private let _error: Swift.Error
    
    init(error: Swift.Error) {
        self._error = error
    }
    
    override func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        observer.on(.error(self._error))
        return Disposables.create()
    }
}
