//
//  UUID+Ext.swift
//  Pomodoro
//
//  Created by Riley Lai on 2023/1/14.
//

import Foundation

extension UUID {
    func new(storeWithKey idKey: String) -> String {
        let uuid = self.uuidString
        UserDefaults.standard.set(uuid, forKey: idKey)
        return uuid
    }
}
