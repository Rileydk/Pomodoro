//
//  UserDefaultValue.swift
//  Pomodoro
//
//  Created by kgcoc on 2023/1/25.
//

import Foundation

@propertyWrapper
struct UserDefaultValue<Value> {
    let userDefault = UserDefaults.standard
    let userDefaultKey: String
    let defaultValue: Value

    var wrappedValue: Value {
        get {
            userDefault.value(forKey: userDefaultKey) as? Value ?? defaultValue
        }

        set {
            userDefault.set(newValue, forKey: userDefaultKey)
        }
    }
}
