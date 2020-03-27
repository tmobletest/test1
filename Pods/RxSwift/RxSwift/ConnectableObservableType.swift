//
//  ConnectableObservableType.swift
//  RxSwift
//
//


public protocol ConnectableObservableType : ObservableType {
  
    func connect() -> Disposable
}
