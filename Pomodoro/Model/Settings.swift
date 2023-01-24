//
//  Settings.swift
//  Pomodoro
//
//  Created by kgcoc on 2023/1/24.
//

import UIKit

struct SettingItem: Hashable {
    let item: Item
    let settingCategory: SettingCategory
    var isOn: Bool = false
    var durations: [Int] = []

    var timesString: String {
        let strList = durations.map { String($0) }
        return "\(strList.joined(separator: ", "))分鐘"
    }
}

enum Item: CaseIterable, Hashable {

    static let allCases: [Item] = [
        .flowPeriod([]), .restPeriod([]), .autoStartRest, .autoStartFlow, .alert, .appleHealth, .tempo, .about, .how, .reset
    ]

    case flowPeriod([Int]), restPeriod([Int]), autoStartRest, autoStartFlow, alert, appleHealth, tempo, about, how, reset

    var description: String {
        switch self {
        case .flowPeriod: return "Flow 時長"
        case .restPeriod: return "休息時長"
        case .autoStartRest: return "自動開始休息"
        case .autoStartFlow: return "自動開始 Flows"
        case .alert: return "通知"
        case .appleHealth: return "Apple 健康"
        case .tempo: return "節拍器"
        case .about: return "關於"
        case .how: return "如何運作"
        case .reset: return "重置統計數據"
        }
    }

    var value: String {
        switch self {
        case .flowPeriod: return "flowPeriod"
        case .restPeriod: return "restPeriod"
        case .autoStartRest: return "autoStartRest"
        case .autoStartFlow: return "autoStartFlow"
        case .alert: return "alert"
        case .appleHealth: return "appleHealth"
        case .tempo: return "tempo"
        case .about: return "about"
        case .how: return "how"
        case .reset: return "reset"
        }
    }

    var itemType: ItemType {
        switch self {
        case .flowPeriod, .restPeriod: return .pushWithTextType
        case .about: return .pushType
        case .how: return .presentType
        case .reset: return .plain
        default: return .switchType
        }
    }

    var image: UIImage? {
        switch self {
        case .alert: return UIImage(systemName: "bell")
        case .appleHealth: return UIImage(systemName: "heart.text.square")
        case .tempo: return UIImage(systemName: "metronome")
        case .about: return UIImage(systemName: "info.circle")
        case .how: return UIImage(systemName: "questionmark.circle")
        default:
            return nil
        }
    }

    var destVC: UIViewController? {
        switch self {
        case .flowPeriod(let duarations): return DurationViewController(durationType: .flowDuration, item: self)
        case .restPeriod(let duarations): return DurationViewController(durationType: .breakDuration, item: self)
        case .about: return UIViewController()
        case .how: return UIViewController()
        default: return nil
        }
    }
}

enum ItemType {
    case pushType, pushWithTextType ,presentType, switchType, plain
}

enum SettingCategory: CaseIterable {
    case session, general, about, reset

    var description: String {
        switch self {
        case .session:
            return "會話"
        case .general:
            return "通用"
        case .about:
            return "關於"
        case .reset:
            return ""
        }
    }
}
