//
//  TimerLifeProtocol.swift
//  Pomodoro
//
//  Created by Riley Lai on 2023/2/2.
//

import Foundation
import UIKit

/// Working with TimerViewModel to get the notification of app life cycle
/// > Declare a TimerViewModel instance as the required timerViewModel,
/// then call `addTimerLifeCycleObserver` to make the `TimerLifeCycleController` work.
protocol TimerLifeCycleController {
    var timerViewModel: TimerViewModel { get }
}

extension TimerLifeCycleController {
    /// Call this method in init or viewDidLoad to add the observer
    /// to make timer life cycle working along with the app life cycle.
    func addTimerLifeCycleObserver() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil, queue: nil) { _ in
                self.enterBackground(timerViewModel)
            }
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil, queue: nil) { _ in
                self.becomeActive(timerViewModel)
            }
        NotificationCenter.default.addObserver(
            forName: UIApplication.willTerminateNotification,
            object: nil, queue: nil) { _ in
                self.applicationWillTerminate(timerViewModel)
            }
    }

    func enterBackground(_ timer: TimerViewModel) {
        timer.prepareForEnterBackground()
    }

    func becomeActive(_ timer: TimerViewModel) {
        timer.prepareForBecomeActive()
    }

    func applicationWillTerminate(_ timer: TimerViewModel) {
        timer.clearNotification()
    }
}
