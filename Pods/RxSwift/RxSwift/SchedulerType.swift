//
//  SchedulerType.swift
//  RxSwift
//
//

import enum Dispatch.DispatchTimeInterval
import struct Foundation.Date

// Type that represents time interval in the context of RxSwift.
public typealias RxTimeInterval = DispatchTimeInterval

/// Type that represents absolute time in the context of RxSwift.
public typealias RxTime = Date

/// Represents an object that schedules units of work.
public protocol SchedulerType: ImmediateSchedulerType {

    /// - returns: Current time.
    var now : RxTime {
        get
    }

   
    func scheduleRelative<StateType>(_ state: StateType, dueTime: RxTimeInterval, action: @escaping (StateType) -> Disposable) -> Disposable
 
    
    func schedulePeriodic<StateType>(_ state: StateType, startAfter: RxTimeInterval, period: RxTimeInterval, action: @escaping (StateType) -> StateType) -> Disposable
}

extension SchedulerType {

    
    public func schedulePeriodic<StateType>(_ state: StateType, startAfter: RxTimeInterval, period: RxTimeInterval, action: @escaping (StateType) -> StateType) -> Disposable {
        let schedule = SchedulePeriodicRecursive(scheduler: self, startAfter: startAfter, period: period, action: action, state: state)
            
        return schedule.start()
    }

    func scheduleRecursive<State>(_ state: State, dueTime: RxTimeInterval, action: @escaping (State, AnyRecursiveScheduler<State>) -> Void) -> Disposable {
        let scheduler = AnyRecursiveScheduler(scheduler: self, action: action)
         
        scheduler.schedule(state, dueTime: dueTime)
            
        return Disposables.create(with: scheduler.dispose)
    }
}
