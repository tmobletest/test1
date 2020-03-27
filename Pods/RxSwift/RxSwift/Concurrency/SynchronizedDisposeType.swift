//
//  SynchronizedDisposeType.swift
//  RxSwift
//
//

protocol SynchronizedDisposeType : class, Disposable, Lock {
    func _synchronized_dispose()
}

extension SynchronizedDisposeType {
    func synchronizedDispose() {
        self.lock(); defer { self.unlock() }
        self._synchronized_dispose()
    }
}
