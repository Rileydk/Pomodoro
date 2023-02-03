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
        static var rounds = 4
        static var automaticallyStartBreak = false
        static var automaticallyStartNextRound = false
    }

    enum NotificationKey {
        /// Used to store notification's identifier in case we need to remove it before triggered
        static let countdownFinished = "countdownFinished"
        static var startDate = "start date"
    }

    static func clearAllUserDefaults() {
        UserDefaults.standard.set(nil, forKey: UserDefaults.NotificationKey.startDate)
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

    private var timer: DispatchSourceTimer?

    /// Used to pass the updated time left to View Controller
    var timeLabelBinder: ((String) -> Void)? {
        didSet {
            timeLabelBinder?(timeLeftText)
        }
    }

    /// Used to pass the countdown state to View Controller
    var countdownStateBinder: ((Bool, Bool, Bool) -> Void)? {
        didSet {
            countdownStateBinder?(startButtonShouldHide,
                                  pauseButtonShouldHide,
                                  resumeAndResetButtonsShouldHide)
        }
    }

    /// Used to pass the countdown type to View Controller
    var countdownTypeBinder: ((CountdownType) -> Void)? {
        didSet {
            countdownTypeBinder?(countdownType)
        }
    }

    /// Represent the state of timer
    private var countdownState: CountdownState = .notStart {
        didSet {
            notifyOtherDevicesCountdownState()
            countdownStateBinder?(startButtonShouldHide,
                                  pauseButtonShouldHide,
                                  resumeAndResetButtonsShouldHide)
            if countdownState == .finished {
                UserDefaults.standard.removeObject(
                    forKey: UserDefaults.NotificationKey.startDate)
                pushToNextRound()
                resetRound()
            }
        }
    }

    /// Represent the type of counting
    private var countdownType: CountdownType = .focus {
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
    private var timeLeftText = {
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
    private var currentRound = 0

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

    private var startButtonShouldHide: Bool {
        switch countdownState {
        case .counting, .paused,
             .notStart where automaticallyStartBreak:
            return true
        default:
            return false
        }
    }

    private var pauseButtonShouldHide: Bool {
        switch countdownState {
        case .counting,
             .notStart where automaticallyStartBreak:
            return false
        default:
            return true
        }
    }

    private var resumeAndResetButtonsShouldHide: Bool {
        switch countdownState {
        case .paused: return false
        default: return true
        }
    }

    // MARK: - Timer Control
    func startTimer() {
        activateTimer()

        DispatchQueue.main.async {
            if self.currentRound == 0 {
                self.currentRound = 1
            }
            self.countdownState = .counting

            // 每次計時完成、重置或 app 終止後，startDate 都會清空。
            // 因此若 startDate 為 nil，表示是還在計時中，但因曾因暫停而移除通知，需要按剩餘時間重新開始計時，因此要重新設定本地通知和通知其他設備。
            // 若不是 nil，表示只是曾退到背景又回到前景，計時持續進行，不需重新設定。
            if UserDefaults.standard.object(
                forKey: UserDefaults.NotificationKey.startDate) as? Date == nil {
                // secondsPassed 有可能是 0，但若在暫停後繼續計時的情況，則已有經過的秒數。
                // 以直接重新指派自身、以觸發 didSet 的方式計算正確的 timeLeft。
                self.secondsPassed = self.secondsPassed
                self.notifyUserCountdownFinished(afterSeconds: self.timeLeft)
                self.storePresentCountdownInfo(startDate: Date())
            }
        }
    }

    private func activateTimer() {
        let queue = DispatchQueue(label: "com.pomodoro.app.timer", qos: .userInitiated)
        timer = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
        timer?.schedule(deadline: .now(), repeating: .seconds(1), leeway: .nanoseconds(0))
        timer?.setEventHandler {
            DispatchQueue.main.async { [weak self] in
                self?.counting()
            }
        }
        timer?.activate()
    }

    func pauseTimer() {
        timer?.cancel()
        countdownState = .paused
        clearNotification()
    }

    func resetRound() {
        timer?.cancel()
        // 若是計時過程中重置，而不是因為時間到歸零，還需要清空通知
        // 目前尚未開發計時過程中重置的功能，預計未來擴充
        if timeLeft != 0 {
            clearNotification()
        }

        countdownState = .notStart
        secondsPassed = 0
    }

    func clearNotification() {
        CountdownNotification.removeAllPendingNotification()
        UserDefaults.clearAllUserDefaults()
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

    func prepareForEnterBackground() {
        timer?.cancel()
    }

    func prepareForBecomeActive() {
        if let startDate = UserDefaults.standard.object(
            forKey: UserDefaults.NotificationKey.startDate) as? Date,
           countdownState == .counting {
            secondsPassed = Int(Date() - startDate)

            if timeLeft > 0 {
                startTimer()
            } else {
                countdownState = .finished
            }
        } else {
            print("=== No stored start date or not counting")
        }
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
