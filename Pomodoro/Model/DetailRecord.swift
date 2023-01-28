//
//  DetailRecord.swift
//  Pomodoro
//
//  Created by kgcoc on 2023/1/28.
//

import Foundation

struct DetailRecord {
    let startTimestamp: Date
    let endTimestamp: Date
    let startLocalTimestamp: Date
    let startYear: Int16
    let startMonth: Int16
    let startWeekOfYear: Int16
    let startDay: Int16
    let durationMinutes: Int32
}

extension DetailRecord {
    init(record: Focus) {
        self.startTimestamp = record.startTimestamp!
        self.endTimestamp = record.endTimestamp!
        self.startLocalTimestamp = record.startTimestamp!.localDate()
        self.startYear = record.startYear
        self.startMonth = record.startMonth
        self.startWeekOfYear = record.startWeekOfYear
        self.startDay = record.startDay
        self.durationMinutes = record.durationMinutes
    }
    
    init(record: Rest) {
        self.startTimestamp = record.startTimestamp!
        self.endTimestamp = record.endTimestamp!
        self.startLocalTimestamp = record.startTimestamp!.localDate()
        self.startYear = record.startYear
        self.startMonth = record.startMonth
        self.startWeekOfYear = record.startWeekOfYear
        self.startDay = record.startDay
        self.durationMinutes = record.durationMinutes
    }
}

protocol RestFocus {
}

extension Rest: RestFocus {

}

extension Focus: RestFocus {

}
