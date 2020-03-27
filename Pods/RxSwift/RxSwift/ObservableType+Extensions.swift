//
//  ObservableType+Extensions.swift
//  RxSwift
//
//

#if DEBUG
    import Foundation
#endif

extension ObservableType {
    
    public func subscribe(_ on: @escaping (Event<Element>) -> Void)
        -> Disposable {
            let observer = AnonymousObserver { e in
                on(e)
            }
            return self.asObservable().subscribe(observer)
    }
    
    
    public func subscribe(onNext: ((Element) -> Void)? = nil, onError: ((Swift.Error) -> Void)? = nil, onCompleted: (() -> Void)? = nil, onDisposed: (() -> Void)? = nil)
        -> Disposable {
            let disposable: Disposable
            
            if let disposed = onDisposed {
                disposable = Disposables.create(with: disposed)
            }
            else {
                disposable = Disposables.create()
            }
            
            #if DEBUG
                let synchronizationTracker = SynchronizationTracker()
            #endif
            
            let callStack = Hooks.recordCallStackOnError ? Hooks.customCaptureSubscriptionCallstack() : []
            
            let observer = AnonymousObserver<Element> { event in
                
                #if DEBUG
                    synchronizationTracker.register(synchronizationErrorMessage: .default)
                    defer { synchronizationTracker.unregister() }
                #endif
                
                switch event {
                case .next(let value):
                    onNext?(value)
                case .error(let error):
                    if let onError = onError {
                        onError(error)
                    }
                    else {
                        Hooks.defaultErrorHandler(callStack, error)
                    }
                    disposable.dispose()
                case .completed:
                    onCompleted?()
                    disposable.dispose()
                }
            }
            return Disposables.create(
                self.asObservable().subscribe(observer),
                disposable
            )
    }
}

import class Foundation.NSRecursiveLock

extension Hooks {
    public typealias DefaultErrorHandler = (_ subscriptionCallStack: [String], _ error: Error) -> Void
    public typealias CustomCaptureSubscriptionCallstack = () -> [String]

    fileprivate static let _lock = RecursiveLock()
    fileprivate static var _defaultErrorHandler: DefaultErrorHandler = { subscriptionCallStack, error in
        #if DEBUG
            let serializedCallStack = subscriptionCallStack.joined(separator: "\n")
            print("Unhandled error happened: \(error)\n subscription called from:\n\(serializedCallStack)")
        #endif
    }
    fileprivate static var _customCaptureSubscriptionCallstack: CustomCaptureSubscriptionCallstack = {
        #if DEBUG
            return Thread.callStackSymbols
        #else
            return []
        #endif
    }

    /// Error handler called in case onError handler wasn't provided.
    public static var defaultErrorHandler: DefaultErrorHandler {
        get {
            _lock.lock(); defer { _lock.unlock() }
            return _defaultErrorHandler
        }
        set {
            _lock.lock(); defer { _lock.unlock() }
            _defaultErrorHandler = newValue
        }
    }
    
    /// Subscription callstack block to fetch custom callstack information.
    public static var customCaptureSubscriptionCallstack: CustomCaptureSubscriptionCallstack {
        get {
            _lock.lock(); defer { _lock.unlock() }
            return _customCaptureSubscriptionCallstack
        }
        set {
            _lock.lock(); defer { _lock.unlock() }
            _customCaptureSubscriptionCallstack = newValue
        }
    }
}

