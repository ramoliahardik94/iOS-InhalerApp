//
//  Dispatch.swift

import Foundation

public func delay(_ delay: Double, _ closure:@escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+delay, execute: closure) // (deadline: .now()+delay, execute: closure)
}

public func background(_ block:@escaping () -> Void) {
    DispatchQueue.global(qos: .default).async(execute: { () -> Void in
        block()
    })
}

public func foreground(_ block:@escaping () -> Void) {
    DispatchQueue.main.async(execute: { () -> Void in
        block()
    })
}
