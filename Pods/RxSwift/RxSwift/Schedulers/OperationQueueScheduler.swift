//
//  OperationQueueScheduler.swift
//  RxSwift
//
d.
//

import class Foundation.Operation
import class Foundation.OperationQueue
import class Foundation.BlockOperation
import Dispatch

/// Abstracts the work that needs to be performed on a specific `NSOperationQueue`.
///
/// This scheduler is suitable for cases when there is some bigger chunk of work that needs to be performed in background and you want to fine tune concurrent processing using `maxConcurrentOperationCount`.
public class OperationQueueScheduler: ImmediateSchedulerType {
    public let operationQueue: OperationQueue
    public let queuePriority: Operation.QueuePriority
    
    /// Constructs new instance of `OperationQueueScheduler` that performs work on `operationQueue`.
    ///
    /// - parameter operationQueue: Operation queue targeted to perform work on.
    /// - parameter queuePriority: Queue priority which will be assigned to new operations.
    public init(operationQueue: OperationQueue, queuePriority: Operation.QueuePriority = .normal) {
        self.operationQueue = operationQueue
        self.queuePriority = queuePriority
    }
    
    
    public func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable {
        let cancel = SingleAssignmentDisposable()

        let operation = BlockOperation {
            if cancel.isDisposed {
                return
            }


            cancel.setDisposable(action(state))
        }

        operation.queuePriority = self.queuePriority

        self.operationQueue.addOperation(operation)
        
        return cancel
    }

}
