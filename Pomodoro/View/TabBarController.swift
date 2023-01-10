//
//  TabBarController.swift
//  Pomodoro
//
//  Created by Riley Lai on 2023/1/5.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVCs()
        configureViews()
    }

    private func setupVCs() {
        viewControllers = Tab.allCases.map {
            $0.controller()
        }
        selectedIndex = 1
    }

    private func configureViews() {
        tabBar.tintColor = .customInfoColor
    }
}

extension TabBarController {
    private enum Tab: Int, CaseIterable {
        case records, timer, settings

        func controller() -> UIViewController {
            var controller: UIViewController

            switch self {
            case .records:
                controller = RecordsViewController()
            case .timer:
                controller = TimerViewController()
            case .settings:
                controller = SettingsViewController()
            }

            controller.tabBarItem = tabBarItem()

            return controller
        }

        func tabBarItem() -> UITabBarItem {
            var barItem: UITabBarItem

            switch self {
            case .records:
                barItem = UITabBarItem(
                    title: "Records",
                    image: UIImage(systemName: "chart.bar"),
                    selectedImage: UIImage(systemName: "chart.bar.fill"))
            case .timer:
                barItem = UITabBarItem(
                    title: "Timer",
                    image: UIImage(systemName: "clock"),
                    selectedImage: UIImage(systemName: "clock.fill"))
            case .settings:
                barItem = UITabBarItem(
                    title: "Settings",
                    image: UIImage(systemName: "gearshape"),
                    selectedImage: UIImage(systemName: "gearshape.fill"))
            }
            return barItem
        }
    }
}
