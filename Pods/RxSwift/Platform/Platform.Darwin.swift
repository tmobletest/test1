//
//  Platform.Darwin.swift
//  Platform
//

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)

    import Darwin
    import class Foundation.Thread
    import protocol Foundation.NSCopying

    extension Thread {
        static func setThreadLocalStorageValue<T: AnyObject>(_ value: T?, forKey key: NSCopying) {
            let currentThread = Thread.current
            let threadDictionary = currentThread.threadDictionary

            if let newValue = value {
                threadDictionary[key] = newValue
            }
            else {
                threadDictionary[key] = nil
            }
        }

        static func getThreadLocalStorageValueForKey<T>(_ key: NSCopying) -> T? {
            let currentThread = Thread.current
            let threadDictionary = currentThread.threadDictionary
            
            return threadDictionary[key] as? T
        }
    }

#endif
