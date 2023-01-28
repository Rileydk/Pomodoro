//
//  PDUbiquitousPropertyValue.swift
//  Pomodoro
//
//  Created by kgcoc on 2023/1/24.
//

import UIKit
@propertyWrapper

struct PDUbiquitousPropertyValue<T> {
    private let key: String
    private let defaultValue: T

    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            return NSUbiquitousKeyValueStore.default.object(forKey: key) as? T ?? defaultValue
        }
        set {
            NSUbiquitousKeyValueStore.default.set(newValue, forKey: key)
            NSUbiquitousKeyValueStore.default.synchronize()
        }
    }
}

struct SettingsValue {
    @PDUbiquitousPropertyValue(key: "flowDuration", defaultValue: [0])
    static var flowDuration: [Int]

    @PDUbiquitousPropertyValue(key: "breakDuration", defaultValue: [0, 0])
    static var breakDuration: [Int]

    @PDUbiquitousPropertyValue(key: "autoStartBreak", defaultValue: false)
    static var autoStartBreak: Bool

    @PDUbiquitousPropertyValue(key: "autoStartFlow", defaultValue: false)
    static var autoStartFlow: Bool

    @PDUbiquitousPropertyValue(key: "notification", defaultValue: false)
    static var notification: Bool

    @PDUbiquitousPropertyValue(key: "appleHealth", defaultValue: false)
    static var appleHealth: Bool

    @PDUbiquitousPropertyValue(key: "metronome", defaultValue: false)
    static var metronome: Bool

    @PDUbiquitousPropertyValue(key: "isReportUpdated", defaultValue: false)
    static var isReportUpdated: Bool

    @PDUbiquitousPropertyValue(key: "deviceTokens", defaultValue: [])
    static var deviceTokens: [String]

    static func setCloudKeyValue<T>(key: String, value: T) {
        NSUbiquitousKeyValueStore.default.set(value, forKey: key)
        NSUbiquitousKeyValueStore.default.synchronize()
    }
}
