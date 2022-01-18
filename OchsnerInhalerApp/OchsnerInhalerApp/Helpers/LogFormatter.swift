//
//  LogFormatter.swift

import Foundation
import CocoaLumberjack

class LogFormatter: NSObject, DDLogFormatter {
    
    func format(message logMessage: DDLogMessage) -> String? {
        var prefix = ""
        switch logMessage.flag {
        case .debug:
            prefix = "DEBUG | "
        case .error:
            prefix = "ERROR \(logMessage.fileName):\(logMessage.function ?? ""):\(logMessage.line) | "
        case .info:
            prefix = "INFO | "
        case .warning:
            prefix = "WARNING | "
        case .verbose:
            prefix = "VERBOSE \(logMessage.fileName):\(logMessage.function ?? ""):\(logMessage.line) | "
        default:
            prefix = "LOG FLAG \(logMessage.flag) | "
        }
        
        return "\(UTCToLocal(UTCDateString: String(describing: logMessage.timestamp))) \(prefix) \(logMessage.message)"
    }
    
    func UTCToLocal(UTCDateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ" // Input Format
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        
        guard let UTCDate = dateFormatter.date(from: UTCDateString) else {
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss a" // Output Format
            dateFormatter.timeZone = TimeZone.current
            return dateFormatter.string(from: Date())
        }
        
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss a" // Output Format
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: UTCDate)
    }
}
