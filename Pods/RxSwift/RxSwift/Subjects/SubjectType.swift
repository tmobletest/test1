//
//  SubjectType.swift
//  RxSwift
//
//

/// Represents an object that is both an observable sequence as well as an observer.
public protocol SubjectType : ObservableType {
    /// The type of the observer that represents this subject.
    ///
    /// Usually this type is type of subject itself, but it doesn't have to be.
    associatedtype Observer: ObserverType

    @available(*, deprecated, message: "Use `Observer` instead.")
    typealias SubjectObserverType = Observer

    /// Returns observer interface for subject.
    ///
    /// - returns: Observer interface for subject.
    func asObserver() -> Observer
    
}
