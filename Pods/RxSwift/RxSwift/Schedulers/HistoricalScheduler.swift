//
//  HistoricalScheduler.swift
//  RxSwift
//
//

import struct Foundation.Date

/// Provides a virtual time scheduler that uses `Date` for absolute time and `NSTimeInterval` for relative time.
public class HistoricalScheduler : VirtualTimeScheduler<HistoricalSchedulerTimeConverter> {

   
    public init(initialClock: RxTime = Date(timeIntervalSince1970: 0)) {
        super.init(initialClock: initialClock, converter: HistoricalSchedulerTimeConverter())
    }
}
