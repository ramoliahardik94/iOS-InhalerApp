//
//  DateTime+Extension.swift

import Foundation

extension Date {
    func getTimeStamp() -> TimeInterval {
        return self.timeIntervalSince1970 * 1000// Converted to miliseconds
    }
    
    func getString(format: String = "dd/MM/yyyy hh:mm a", isUTC: Bool = false) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = isUTC ? TimeZone(identifier: "UTC") : .current
        return formatter.string(from: self)
    }
        static var yesterday: Date { return Date().dayBefore }
        static var tomorrow:  Date { return Date().dayAfter }
        var dayBefore: Date {
            return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
        }
        var dayAfter: Date {
            return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
        }
        var noon: Date {
            return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
        }
        var month: Int {
            return Calendar.current.component(.month,  from: self)
        }
        var isLastDayOfMonth: Bool {
            return dayAfter.month != month
        }

    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {

            let currentCalendar = Calendar.current

            guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
            guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }

            return end - start
        }
}

extension TimeInterval {
    func getDateTime(format: String = "dd/MM/yyyy hh:mm a", _ isEpoch: Bool = true) -> String? {
        let formatter = DateFormatter()
        let date = Date(timeIntervalSince1970: (isEpoch ? self/1000 : self))// Converted from miliseconds to seconds
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    func getDate(_ isEpoch: Bool = true) -> Date {
        return Date(timeIntervalSince1970: (isEpoch ? self/1000 : self))
    }
}

extension String {
    func getDate(format: String = "dd/MM/yyyy hh:mm a", isUTC: Bool = false) -> Date {
        let defaultStr = Date().getString(format: format)
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = isUTC ? TimeZone(identifier: "UTC") : .current
        return formatter.date(from: self) ?? formatter.date(from: defaultStr)!
    }
    func isDateVallid(format: String = "yyyy-MM-dd") -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        guard formatter.date(from: self) != nil else { return false }
        return true
    }
}
