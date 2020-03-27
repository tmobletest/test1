//
//  String+Rx.swift
//  RxSwift
//
//

extension String {
    /// This is needed because on Linux Swift doesn't have `rangeOfString(..., options: .BackwardsSearch)`
    func lastIndexOf(_ character: Character) -> Index? {
        var index = self.endIndex
        while index > self.startIndex {
            index = self.index(before: index)
            if self[index] == character {
                return index
            }
        }

        return nil
    }
}
