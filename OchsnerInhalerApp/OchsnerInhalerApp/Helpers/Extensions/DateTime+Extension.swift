//
//  DateTime+Extension.swift

import Foundation

extension Date {
    func getTimeStamp() -> TimeInterval {
        return self.timeIntervalSince1970 * 1000//Converted to miliseconds
    }
    
    func getString(format: String = "dd/MM/yyyy hh:mm a", isUTC: Bool = false) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = isUTC ? TimeZone(identifier: "UTC") : .current
        return formatter.string(from: self)
    }
}

extension TimeInterval {
    func getDateTime(format: String = "dd/MM/yyyy hh:mm a", _ isEpoch: Bool = true) -> String? {
        let formatter = DateFormatter()
        let date = Date(timeIntervalSince1970: (isEpoch ? self/1000 : self))//Converted from miliseconds to seconds
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    func getDate(_ isEpoch: Bool = true) -> Date {
        return Date(timeIntervalSince1970: (isEpoch ? self/1000 : self))
    }
}

extension String {
    func getDate(format: String = "dd/MM/yyyy hh:mm a", isUTC: Bool = false) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = isUTC ? TimeZone(identifier: "UTC") : .current
        return formatter.date(from: self)!
    }
}
