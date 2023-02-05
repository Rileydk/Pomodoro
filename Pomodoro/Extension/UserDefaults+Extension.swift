//
//  UserDefaults+Extension.swift
//  Pomodoro
//
//  Created by kgcoc on 2023/1/25.
//

import Foundation

extension UserDefaults {
    @UserDefaultValue(userDefaultKey: "currentDeviceToken", defaultValue: "")
    static var currentDeviceToken: String
}
