//
//  InvocableScheduledItem.swift
//  RxSwift
//
//

struct InvocableScheduledItem<I: InvocableWithValueType> : InvocableType {

    let _invocable: I
    let _state: I.Value

    init(invocable: I, state: I.Value) {
        self._invocable = invocable
        self._state = state
    }

    func invoke() {
        self._invocable.invoke(self._state)
    }
}
