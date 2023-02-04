//
//  DateFormatter+Extension.swift
//  Pomodoro
//
//  Created by kgcoc on 2023/2/4.
//

import Foundation

extension DateFormatter {
    static func datetimeStringToDate(datetimeString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "zh_tw")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.date(from: datetimeString) ?? Date()
    }

    static func datetimeDateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "zh_tw")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: date)
    }
}
