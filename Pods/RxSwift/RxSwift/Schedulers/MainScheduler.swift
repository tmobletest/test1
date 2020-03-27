//
//  MainScheduler.swift
//  RxSwift
//

//

import Dispatch
#if !os(Linux)
    import Foundation
#endif

public final class MainScheduler : SerialDispatchQueueScheduler {

    private let _mainQueue: DispatchQueue

    let numberEnqueued = AtomicInt(0)

    /// Initializes new instance of `MainScheduler`.
    public init() {
        self._mainQueue = DispatchQueue.main
        super.init(serialQueue: self._mainQueue)
    }

    /// Singleton instance of `MainScheduler`
    public static let instance = MainScheduler()

    /// Singleton instance of `MainScheduler` that always schedules work asynchronously
    /// and doesn't perform optimizations for calls scheduled from main queue.
    public static let asyncInstance = SerialDispatchQueueScheduler(serialQueue: DispatchQueue.main)

    /// In case this method is called on a background thread it will throw an exception.
    public class func ensureExecutingOnScheduler(errorMessage: String? = nil) {
        if !DispatchQueue.isMain {
            rxFatalError(errorMessage ?? "Executing on background thread. Please use `MainScheduler.instance.schedule` to schedule work on main thread.")
        }
    }

    /// In case this method is running on a background thread it will throw an exception.
    public class func ensureRunningOnMainThread(errorMessage: String? = nil) {
        #if !os(Linux) // isMainThread is not implemented in Linux Foundation
            guard Thread.isMainThread else {
                rxFatalError(errorMessage ?? "Running on background thread.")
            }
        #endif
    }

    override func scheduleInternal<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable {
        let previousNumberEnqueued = increment(self.numberEnqueued)

        if DispatchQueue.isMain && previousNumberEnqueued == 0 {
            let disposable = action(state)
            decrement(self.numberEnqueued)
            return disposable
        }

        let cancel = SingleAssignmentDisposable()

        self._mainQueue.async {
            if !cancel.isDisposed {
                _ = action(state)
            }

            decrement(self.numberEnqueued)
        }

        return cancel
    }
}
