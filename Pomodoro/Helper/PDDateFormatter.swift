//
//  PDDateFormatter.swift
//  Pomodoro
//
//  Created by kgcoc on 2023/1/28.
//

import Foundation

class PDDateFormatter {
    static let shared = PDDateFormatter()

    private init(){}

    let formatter = DateComponentsFormatter()

    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "zh_tw")
        return dateFormatter
    }()

    func datetimeStringToDate(datetimeString: String) -> Date {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        print(datetimeString)
        return dateFormatter.date(from: datetimeString) ?? Date()
    }

    func datetimeDateToString(date: Date) -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: date)
    }
}
