//
//  Int+Extension.swift
//  MangaSocial
//

import Foundation

extension Int {
    public func toString() -> String {
        return "\(self)"
    }
}
extension Double {
    func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second, .nanosecond]
        formatter.unitsStyle = style
        return formatter.string(from: self) ?? ""
    }
}
