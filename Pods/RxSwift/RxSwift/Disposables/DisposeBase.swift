//
//  DisposeBase.swift
//  RxSwift
//
//

/// Base class for all disposables.
public class DisposeBase {
    init() {
#if TRACE_RESOURCES
    _ = Resources.incrementTotal()
#endif
    }
    
    deinit {
#if TRACE_RESOURCES
    _ = Resources.decrementTotal()
#endif
    }
}
