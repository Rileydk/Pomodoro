//
//  SettingsViewModel.swift
//  Pomodoro
//
//  Created by kgcoc on 2023/1/24.
//

import RxSwift

class SettingsViewModel {

    var settingItems = PublishSubject<[SettingItem]>()

    var items: [String: SettingItem] = [
        "flowPeriod": SettingItem(item: .flowPeriod([5]), settingCategory: .session),
        "restPeriod": SettingItem(item: .restPeriod([5, 10]), settingCategory: .session),
        "autoStartRest": SettingItem(item: .autoStartRest, settingCategory: .session),
        "autoStartFlow": SettingItem(item: .autoStartFlow, settingCategory: .session),
        "alert": SettingItem(item: .alert, settingCategory: .general),
        "appleHealth": SettingItem(item: .appleHealth, settingCategory: .general),
        "tempo": SettingItem(item: .tempo, settingCategory: .general),
        "about": SettingItem(item: .about, settingCategory: .about),
        "how": SettingItem(item: .how, settingCategory: .about),
        "reset": SettingItem(item: .reset, settingCategory: .reset)
    ]

    func fetchConfiguration() {
        var results: [SettingItem] = []
        Item.allCases.forEach { item in
            results.append(items[item.value]!)
        }
        settingItems.onNext(results)
    }

    func updateConfiguration(type: Item, isOn: Bool) {
        items[type.value]?.isOn = isOn
    }
}
