//
//  LockOwnerType.swift
//  RxSwift
//
//

protocol LockOwnerType : class, Lock {
    var _lock: RecursiveLock { get }
}

extension LockOwnerType {
    func lock() {
        self._lock.lock()
    }

    func unlock() {
        self._lock.unlock()
    }
}
