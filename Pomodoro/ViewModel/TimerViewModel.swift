//
//  TimerViewModel.swift
//  Pomodoro
//
//  Created by Riley Lai on 2023/1/10.
//

import Foundation

extension UserDefaults {
    enum TimeLengthPreferences {
        static var focus = 1
        static var shortBreak = 5
        static var longBreak = 15
    }

    enum Session {
        static var rounds = 4
    }
}

class TimerViewModel {

    enum CountdownState {
        case notCounting, counting, paused
    }

    enum CountdownType {
        case focus, `break`
    }

    private var timer: Timer?

    /// Used to pass the updated time left to View Controller
    var timeLabelBinder: ((String) -> Void)?

    /// Used to pass the countdown state to View Controller
    var countdownStateBinder: ((CountdownState) -> Void)?

    /// Represent the state of timer
    var countdownState: CountdownState = .notCounting {
        didSet {
            countdownStateBinder?(countdownState)
        }
    }

    /// Represent the type of counting
    var countdownType: CountdownType = .focus

    /// Seconds passed during timer count down
    private var secondsPassed = 0 {
        didSet {
            timeLeft = UserDefaults.TimeLengthPreferences.focus.toSeconds - secondsPassed
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
            } else {
                countdownState = .notCounting
                timer?.invalidate()
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
    var sessionRounds: Int {
        UserDefaults.Session.rounds
    }

    /// Present round in the present session
    var presentRound = 1

    // MARK: - Timer Control
    func startTimer() {
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(countup),
            userInfo: nil,
            repeats: true)

        RunLoop.current.add(timer!, forMode: .common)
        countdownState = .counting
    }

    func pauseTimer() {
        timer?.invalidate()
        countdownState = .paused
    }

    func stopTimer() {
        timer?.invalidate()
        countdownState = .notCounting
        secondsPassed = 0
    }

    @objc private func countup() {
        secondsPassed += 1
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
