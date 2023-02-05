//
//  PDUbiquitousPropertyValue.swift
//  Pomodoro
//
//  Created by kgcoc on 2023/1/24.
//

import UIKit
@propertyWrapper

struct PDUbiquitousPropertyValue<T> {
    private let propertyKey: String
    private let defaultValue: T

    init(propertyKey: String, defaultValue: T) {
        self.propertyKey = propertyKey
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            return NSUbiquitousKeyValueStore.default.object(forKey: propertyKey) as? T ?? defaultValue
        }
        set {
            NSUbiquitousKeyValueStore.default.set(newValue, forKey: propertyKey)
            NSUbiquitousKeyValueStore.default.synchronize()
        }
    }
}

struct SettingsValue {
    @PDUbiquitousPropertyValue(propertyKey: "flowDuration", defaultValue: [0])
    static var flowDuration: [Int]

    @PDUbiquitousPropertyValue(propertyKey: "breakDuration", defaultValue: [0, 0])
    static var breakDuration: [Int]

    @PDUbiquitousPropertyValue(propertyKey: "autoStartBreak", defaultValue: false)
    static var autoStartBreak: Bool

    @PDUbiquitousPropertyValue(propertyKey: "autoStartFlow", defaultValue: false)
    static var autoStartFlow: Bool

    @PDUbiquitousPropertyValue(propertyKey: "notification", defaultValue: false)
    static var notification: Bool

    @PDUbiquitousPropertyValue(propertyKey: "appleHealth", defaultValue: false)
    static var appleHealth: Bool

    @PDUbiquitousPropertyValue(propertyKey: "metronome", defaultValue: false)
    static var metronome: Bool

    @PDUbiquitousPropertyValue(propertyKey: "isReportUpdated", defaultValue: false)
    static var isReportUpdated: Bool

    @PDUbiquitousPropertyValue(propertyKey: "deviceTokens", defaultValue: [])
    static var deviceTokens: [String]

    static func setCloudKeyValue<T>(propertyKey: String, value: T) {
        NSUbiquitousKeyValueStore.default.set(value, forKey: propertyKey)
        NSUbiquitousKeyValueStore.default.synchronize()
    }
}
