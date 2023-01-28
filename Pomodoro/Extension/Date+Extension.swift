//
//  Date+Extension.swift
//  Pomodoro
//
//  Created by kgcoc on 2023/1/28.
//

import Foundation

extension Date {
    func customDateComponents() -> DateComponents {
        return Calendar.current.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute], from: self)
    }

    func localDate() -> Date {
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: self))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: self) else {return Date()}
        return localDate
    }

    func startOfWeek(using calendar: Calendar = .current) -> Date {
        var components = calendar.dateComponents([.weekday, .year, .month, .weekOfYear], from: self)
        components.weekday = calendar.firstWeekday
        return calendar.date(from: components) ?? self
    }

    func startOfMonth(using calendar: Calendar = .current) -> Date {
        let components = calendar.dateComponents([.year, .month], from: self)
        return  calendar.date(from: components)!
    }
}
