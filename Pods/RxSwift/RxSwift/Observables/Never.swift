//
//  Never.swift
//  RxSwift
//
//

extension ObservableType {

    public static func never() -> Observable<Element> {
        return NeverProducer()
    }
}

final private class NeverProducer<Element>: Producer<Element> {
    override func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        return Disposables.create()
    }
}
