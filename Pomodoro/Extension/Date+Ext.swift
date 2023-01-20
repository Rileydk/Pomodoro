//
//  Date+Ext.swift
//  Pomodoro
//
//  Created by Riley Lai on 2023/1/14.
//

import Foundation

extension Date {
    func endDate(afterSeconds seconds: Int) -> Date? {
        return Calendar.current
                .date(byAdding: .second, value: seconds, to: self)
    }
}
