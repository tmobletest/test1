//
//  SwiftSupport.swift
//  RxSwift
//
//

import Foundation

typealias IntMax = Int64
public typealias RxAbstractInteger = FixedWidthInteger

extension SignedInteger {
    func toIntMax() -> IntMax {
        return IntMax(self)
    }
}
