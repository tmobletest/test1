//
//  ScheduledItemType.swift
//  RxSwift
//
//

protocol ScheduledItemType
    : Cancelable
    , InvocableType {
    func invoke()
}
