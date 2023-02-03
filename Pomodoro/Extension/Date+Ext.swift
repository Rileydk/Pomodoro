//
//  Date+Ext.swift
//  Pomodoro
//
//  Created by Riley Lai on 2023/1/14.
//

import Foundation

extension Date {
    var displayedByTimezone: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        return dateFormatter.string(for: self) ?? "formatted result is nil"
    }

    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        lhs.timeIntervalSince1970 - rhs.timeIntervalSince1970
    }

    func endDate(afterSeconds seconds: Int) -> Date? {
        return Calendar.current
                .date(byAdding: .second, value: seconds, to: self)
    }
}
