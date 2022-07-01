//
//  Logger.swift

import Foundation
import CocoaLumberjack
class Logger {
    
    // MARK: - Lifecycle
    
    private init() {} // Disallows direct instantiation e.g.: "Logger()"
    
    // MARK: - Logging
    
    class func log(_ message: Any = "",
                   withEmoji: Bool = true,
                   filename: String = #file,
                   function: String =  #function,
                   line: Int = #line) {
        
        if withEmoji {
            let body = emojiBody(filename: filename, function: function, line: line)
            emojiLog(messageHeader: emojiHeader(), messageBody: body)
            
        } else {
            let body = regularBody(filename: filename, function: function, line: line)
            regularLog(messageHeader: regularHeader(), messageBody: body)
        }
        
        let messageString = String(describing: message)
        guard !messageString.isEmpty else { return }
        print(" └ 📣 \(messageString)\n")
    }
    
    class func logInfo(_ message: Any = "",
                       filename: String = #file,
                       function: String =  #function,
                       line: Int = #line) {
        
        
        let body = regularBody(filename: filename, function: function, line: line)
        // regularLog(messageHeader: regularHeader(), messageBody: body)
        DDLogInfo("\(body) -> \(message)")
        
        #if DEBUG
        print("\(body) -> \(message)")
        
        #endif
    }
    
    class func logError(_ message: Any = "",
                        filename: String = #file,
                        function: String =  #function,
                        line: Int = #line) {
        
        
        let body = regularBody(filename: filename, function: function, line: line)
        // regularLog(messageHeader: regularHeader(), messageBody: body)
        DDLogError("\(body) -> \(message)")
        
        #if DEBUG
        print("\(body) -> \(message)")
        
        #endif
    }
}

// MARK: - Private

// MARK: Emoji

private extension Logger {
    
    class func emojiHeader() -> String {
        return "⏱ \(formattedDate())"
    }
    
    class func emojiBody(filename: String, function: String, line: Int) -> String {
        return "🗂 \(filenameWithoutPath(filename: filename)), in 🔠 \(function) at #️⃣ \(line)"
    }
    
    class func emojiLog(messageHeader: String, messageBody: String) {
        print("\(messageHeader) │ \(messageBody)")
    }
}

// MARK: Regular

private extension Logger {
    
    class func regularHeader() -> String {
        return " \(formattedDate()) "
    }
    
    class func regularBody(filename: String, function: String, line: Int) -> String {
        return " \(filenameWithoutPath(filename: filename)) -> \(function) -> Line: \(line) "
    }
    
    class func regularLog(messageHeader: String, messageBody: String) {
        let headerHorizontalLine = horizontalLine(for: messageHeader)
        let bodyHorizontalLine = horizontalLine(for: messageBody)
        
        print("┌\(headerHorizontalLine)┬\(bodyHorizontalLine)┐")
        print("│\(messageHeader)│\(messageBody)│")
        print("└\(headerHorizontalLine)┴\(bodyHorizontalLine)┘")
    }
    
    /// Returns a `String` composed by horizontal box-drawing characters (─) based on the given message length.
    ///
    /// For example:
    ///
    ///     " ViewController.swift, in viewDidLoad() at 26 " // Message
    ///     "──────────────────────────────────────────────" // Returned String
    ///
    /// Reference: [U+250x Unicode](https://en.wikipedia.org/wiki/Box-drawing_character)
    class func horizontalLine(for message: String) -> String {
        return Array(repeating: "─", count: message.count).joined()
    }
}

// MARK: Util

private extension Logger {
    
    class func filenameWithoutPath(filename: String) -> String {
        return URL(fileURLWithPath: filename).lastPathComponent
    }
    
    /// E.g. `15:25:04.749`
    class func formattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        return "\(dateFormatter.string(from: Date()))"
    }
}
