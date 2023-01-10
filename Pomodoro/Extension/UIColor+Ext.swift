//
//  UIColor+Ext.swift
//  Pomodoro
//
//  Created by Riley Lai on 2023/1/10.
//

import UIKit

extension UIColor {
    static var customBackgroundColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traits -> UIColor in
                return traits.userInterfaceStyle == .dark ? .black : .white
            }
        } else {
            return .black
        }
    }

    static var customInfoColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traits -> UIColor in
                return traits.userInterfaceStyle == .dark ? .white : .black
            }
        } else {
            return .white
        }
    }
}
