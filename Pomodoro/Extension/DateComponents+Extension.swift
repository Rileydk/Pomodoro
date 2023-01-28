//
//  DateComponents+Extension.swift
//  Pomodoro
//
//  Created by kgcoc on 2023/1/28.
//

import Foundation

extension DateComponents {
    func dateInterval(to: DateComponents) -> Int32 {
        return Int32(Calendar.current.dateComponents([.minute], from: self, to: to).minute!)
    }
}
