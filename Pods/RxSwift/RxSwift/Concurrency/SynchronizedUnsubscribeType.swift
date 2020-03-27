//
//  SynchronizedUnsubscribeType.swift
//  RxSwift
//
//

protocol SynchronizedUnsubscribeType : class {
    associatedtype DisposeKey

    func synchronizedUnsubscribe(_ disposeKey: DisposeKey)
}
