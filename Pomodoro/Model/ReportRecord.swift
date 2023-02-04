//
//  ReportRecord.swift
//  Pomodoro
//
//  Created by kgcoc on 2023/1/28.
//

import Foundation
struct ReportRecord {
    let year: Int16
    var month: Int16?
    var weekOfYear: Int16?
    var dayOfMonth: Int16?
    var date: Date?
    let focusTotal: Int32
    let restTotal: Int32
}

extension ReportRecord {
    init(dailyReport: DailyReport) {
        self.year = dailyReport.year
        self.month = dailyReport.month
        self.dayOfMonth = dailyReport.dayOfMonth
        self.weekOfYear = dailyReport.weekOfYear
        self.date = dailyReport.date
        self.focusTotal = dailyReport.focusTotal
        self.restTotal = dailyReport.restTotal
    }

    init(weeklyReport: WeeklyReport) {
        self.year = weeklyReport.year
        self.weekOfYear = weeklyReport.weekOfYear
        self.restTotal = weeklyReport.restTotal
        self.focusTotal = weeklyReport.focusTotal
    }

    init(monthlyReport: MonthlyReport) {
        self.year = monthlyReport.year
        self.month = monthlyReport.month
        self.restTotal = monthlyReport.restTotal
        self.focusTotal = monthlyReport.focusTotal
    }
}

enum ReportType: CaseIterable {
    case weekly
    case monthly
    case daily
    case focus
    case rest

    var entityName: String {
        switch self {
        case .weekly:
            return "WeeklyReport"
        case .monthly:
            return "MonthlyReport"
        case .daily:
            return "DailyReport"
        case .focus:
            return "Focus"
        case .rest:
            return "Rest"
        }
    }
}
