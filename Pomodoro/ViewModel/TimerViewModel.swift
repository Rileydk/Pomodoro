//
//  TimerViewModel.swift
//  Pomodoro
//
//  Created by Riley Lai on 2023/1/10.
//

import Foundation
import UIKit.UIImage

extension UserDefaults {
    enum TimeLengthPreferences {
        static var focus = 1
        static var shortBreak = 1
        static var longBreak = 2
    }

    enum SessionPreferences {
        static var rounds = 2
        static var automaticallyStartBreak = false
        static var automaticallyStartNextRound = false
    }

    enum NotificationKey {
        /// Used to store notification's identifier in case we need to remove it before triggered
        static let countdownFinished = "countdownFinished"
        static var startDate = "start date"
    }
}

public class TimerViewModel {
    private enum CountdownState {
        /// Round not started yet
        case notStart
        /// Round finished
        case counting
        /// Round start then paused
        case paused
        case finished
    }

    enum CountdownType {
        case focus
        case `break`

        var title: String {
            switch self {
            case .focus: return "Focus"
            case .break: return "Break"
            }
        }

        var notificationTitle: String {
            switch self {
            case .focus: return "專注"
            case .break: return "休息"
            }
        }

        mutating func toggle() {
            switch self {
            case .focus: self = .break
            case .break: self = .focus
            }
        }
    }

    private enum SessionIcon {
        static let empty = UIImage(systemName: "circle")!
        static let half = UIImage(systemName: "circle.lefthalf.filled")!
        static let filled = UIImage(systemName: "circle.fill")!
    }

    private var sourceTimer: DispatchSourceTimer?

    /// Used to pass the updated time left to View Controller
    var timeLabelBinder: ((String) -> Void)?

    /// Used to pass the countdown state to View Controller
    var countdownStateBinder: (() -> Void)?

    /// Used to pass the countdown type to View Controller
    var countdownTypeBinder: ((CountdownType) -> Void)?

    /// Used to pass the session state to View Controller
    var sessionBinder: (() -> Void)?

    /// Represent the state of timer
    private var countdownState: CountdownState = .notStart {
        didSet {
            notifyOtherDevicesCountdownState()
            countdownStateBinder?()
            if countdownState == .finished {
                pushToNextRound()
                resetRound()
            }
        }
    }

    /// Represent the type of counting
    var countdownType: CountdownType = .focus {
        didSet {
            countdownTypeBinder?(countdownType)
        }
    }

    /// Current countdown time length
    private var settingTime: Int {
        let settingTime: Int
        switch countdownType {
        case .focus:
            settingTime = UserDefaults.TimeLengthPreferences.focus
        case .break:
            if isLastRound {
                settingTime = UserDefaults.TimeLengthPreferences.longBreak
            } else {
                settingTime = UserDefaults.TimeLengthPreferences.shortBreak
            }
        }
        return settingTime
    }

    /// Seconds passed during timer count down
    private var secondsPassed = 0 {
        didSet {
            timeLeft = settingTime.toSeconds - secondsPassed
        }
    }

    /// Time left regardless of the count down state
    private var timeLeft: Int = 0 {
        didSet {
            if timeLeft >= 0 {
                timeLeftText = """
                    \(timeLeft.remainMinutes.timeTextified):\
                    \(timeLeft.remainSeconds.timeTextified)
                    """
                if timeLeft == 0 && countdownState == .counting {
                    countdownState = .finished
                }
            }
        }
    }

    /// Time left that should display on timer page
    var timeLeftText = {
        let focusTimeLength = UserDefaults.TimeLengthPreferences.focus.toSeconds
        return """
                \(focusTimeLength.remainMinutes.timeTextified):\
                \(focusTimeLength.remainSeconds.timeTextified)
                """
    }() {
        didSet {
            timeLabelBinder?(timeLeftText)
        }
    }

    /// Rounds per session
    private var sessionRounds: Int {
        UserDefaults.SessionPreferences.rounds
    }

    /// Present round in the present session
    private var currentRound = 0 {
        didSet {
            sessionBinder?()
        }
    }

    private var isLastRound: Bool {
        currentRound == sessionRounds
    }

    /// Used to display the present round in a session
    var sessionImages: [UIImage] {
        var images = [UIImage]()
        for round in 1 ... sessionRounds {
            let image: UIImage
            if round < currentRound {
                image = SessionIcon.filled
            } else if round == currentRound {
                if countdownType == .break && countdownState != .notStart {
                    image = SessionIcon.filled
                } else if countdownType == .break ||
                         (countdownType == .focus && countdownState != .notStart) {
                    image = SessionIcon.half
                } else {
                    image = SessionIcon.empty
                }
            } else {
                image = SessionIcon.empty
            }
            images.append(image)
        }
        return images
    }

    private var automaticallyStartBreak: Bool {
        UserDefaults.SessionPreferences.automaticallyStartBreak
    }

    private var automaticallyStartNextRound: Bool {
        UserDefaults.SessionPreferences.automaticallyStartNextRound
    }

    var startButtonShouldHide: Bool {
        switch countdownState {
        case .counting, .paused,
             .notStart where automaticallyStartBreak:
            return true
        default:
            return false
        }
    }

    var pauseButtonShouldHide: Bool {
        switch countdownState {
        case .counting,
             .notStart where automaticallyStartBreak:
            return false
        default:
            return true
        }
    }

    var resumeAndResetButtonsShouldHide: Bool {
        switch countdownState {
        case .paused: return false
        default: return true
        }
    }

    // MARK: - Timer Control
    func startTimer() {
        let queue = DispatchQueue(label: "com.pomodoro.app.timer", qos: .userInitiated)
        sourceTimer = DispatchSource.makeTimerSource(flags: .strict,queue: queue)
        sourceTimer?.schedule(deadline: .now(), repeating: .seconds(1), leeway: .nanoseconds(0))
        sourceTimer?.setEventHandler {
            DispatchQueue.main.async { [weak self] in
                self?.counting()
            }
        }
        sourceTimer?.activate()

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.currentRound == 0 {
                self.currentRound = 1
            }
            self.countdownState = .counting
            self.notifyUserCountdownFinished(afterSeconds: self.settingTime * 60)
            self.storePresentCountdownInfo(startDate: Date())
        }
    }

    func pauseTimer() {
        sourceTimer?.cancel()
        countdownState = .paused
    }

    func resetRound() {
        sourceTimer?.cancel()
        countdownState = .notStart
        secondsPassed = 0
    }

    private func pushToNextRound() {
        countdownType.toggle()

        if countdownType == .break {
            if automaticallyStartBreak {
                startTimer()
            }
        } else {
            if isLastRound {
                currentRound = 0
            } else {
                currentRound += 1
                if automaticallyStartNextRound {
                    startTimer()
                }
            }
        }
    }

    @objc private func counting() {
        secondsPassed += 1
    }

    private func notifyUserCountdownFinished(afterSeconds seconds: Int? = nil) {
        CountdownNotification.registerNotification(
            type: countdownType,
            startAt: Date(),
            durationBySeconds: seconds)
    }

    private func notifyOtherDevicesCountdownState() {
        // print(#function)
        // 通知所有其他裝置目前計時情形(type, time, state, session)
        // 有變動才通知
        // Push
        // WatchConnectivity
        // 其他裝置收到通知，開啟時各自繼續計時
    }

    private func storePresentCountdownInfo(startDate: Date) {
        // print(#function)
        // 儲存用來通知其他裝置的必要資訊（startTimestamp）(timeLengthPreferences, sessionPreferences 的部分本來就儲存在共同的地方)
        UserDefaults.standard.set(startDate, forKey: UserDefaults.NotificationKey.startDate)
    }

    private func storeCountdownRecord() {
        // print(#function)
        // 儲存完成計時的紀錄到 Core Data
    }
}

fileprivate extension Int {
    var toSeconds: Int {
        self * 60
    }

    var remainSeconds: Int {
        self % 60
    }

    var remainMinutes: Int {
        self / 60
    }

    var timeTextified: String {
        if self == 0 {
            return "00"
        } else if self < 10 {
            return "0" + "\(self)"
        } else {
            return "\(self)"
        }
    }
}
