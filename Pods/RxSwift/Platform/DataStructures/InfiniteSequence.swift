//
//  InfiniteSequence.swift
//  Platform
//
//

/// Sequence that repeats `repeatedValue` infinite number of times.
struct InfiniteSequence<Element> : Sequence {
    typealias Iterator = AnyIterator<Element>
    
    private let _repeatedValue: Element
    
    init(repeatedValue: Element) {
        _repeatedValue = repeatedValue
    }
    
    func makeIterator() -> Iterator {
        let repeatedValue = _repeatedValue
        return AnyIterator {
            return repeatedValue
        }
    }
}
