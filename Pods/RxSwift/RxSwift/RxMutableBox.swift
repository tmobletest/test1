//
//  RxMutableBox.swift
//  RxSwift
//


import class Foundation.NSObject

/// Creates mutable reference wrapper for any type.
final class RxMutableBox<T>: NSObject {
    /// Wrapped value
    var value: T

    /// Creates reference wrapper for `value`.
    ///
    /// - parameter value: Value to wrap.
    init (_ value: T) {
        self.value = value
    }
}
#else
/// Creates mutable reference wrapper for any type.
final class RxMutableBox<T>: CustomDebugStringConvertible {
    /// Wrapped value
    var value: T
    
    /// Creates reference wrapper for `value`.
    ///
    /// - parameter value: Value to wrap.
    init (_ value: T) {
        self.value = value
    }
}

extension RxMutableBox {
    /// - returns: Box description.
    var debugDescription: String {
        return "MutatingBox(\(self.value))"
    }
}
#endif
