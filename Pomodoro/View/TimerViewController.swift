//
//  TimerViewController.swift
//  Pomodoro
//
//  Created by Riley Lai on 2023/1/5.
//

import UIKit

class TimerViewController: UIViewController {

    private let timerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 58, weight: .semibold)
        label.textColor = .customInfoColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let sessionView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var startButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.addTarget(self, action: #selector(startTimer), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var pauseButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.addTarget(self, action: #selector(pauseTimer), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var resumeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.addTarget(self, action: #selector(startTimer), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var stopButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "gobackward"), for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.addTarget(self, action: #selector(stopTimer), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let controlView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 36
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let viewModel: TimerViewModel

    init(viewModel: TimerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        viewModel.timeLabelBinder = { [weak self] timeLeftText in
            self?.timerLabel.text = timeLeftText
        }

        viewModel.countdownStateBinder = { [weak self] countdownState in
            guard let self = self else { return }
            switch countdownState {
            case .counting:
                self.startButton.isHidden = true
                self.pauseButton.isHidden = false
                self.controlView.subviews.forEach { $0.isHidden = true }
            case .notCounting:
                self.startButton.isHidden = false
                self.pauseButton.isHidden = true
                self.controlView.subviews.forEach { $0.isHidden = true }
            case .paused:
                self.startButton.isHidden = true
                self.pauseButton.isHidden = true
                self.controlView.subviews.forEach { $0.isHidden = false }
            }
        }
    }

    private func configureViews() {
        view.backgroundColor = .customBackgroundColor
        [timerLabel, sessionView, startButton, pauseButton, controlView]
            .forEach { view.addSubview($0) }
        [resumeButton, stopButton]
            .forEach { controlView.addArrangedSubview($0) }
        controlView.subviews.forEach { $0.isHidden = true }
        pauseButton.isHidden = true
        configureSessionView()

        timerLabel.text = viewModel.timeLeftText

        let controlViewHeight: CGFloat = 38
        let controlViewTopDistance: CGFloat = 28
        NSLayoutConstraint.activate([
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            sessionView.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 20),
            sessionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            startButton.topAnchor.constraint(
                equalTo: sessionView.bottomAnchor, constant: controlViewTopDistance),
            startButton.heightAnchor.constraint(equalToConstant: controlViewHeight),
            startButton.widthAnchor.constraint(equalTo: startButton.heightAnchor, multiplier: 1),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            pauseButton.topAnchor.constraint(
                equalTo: sessionView.bottomAnchor, constant: controlViewTopDistance),
            pauseButton.heightAnchor.constraint(equalToConstant: controlViewHeight),
            pauseButton.widthAnchor.constraint(equalTo: startButton.heightAnchor, multiplier: 1),
            pauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            resumeButton.heightAnchor.constraint(equalToConstant: controlViewHeight),
            resumeButton.widthAnchor.constraint(equalTo: startButton.heightAnchor, multiplier: 1),

            stopButton.heightAnchor.constraint(equalToConstant: controlViewHeight),
            stopButton.widthAnchor.constraint(equalTo: startButton.heightAnchor, multiplier: 1),

            pauseButton.heightAnchor.constraint(equalToConstant: controlViewHeight),
            pauseButton.widthAnchor.constraint(equalTo: startButton.heightAnchor, multiplier: 1),

            controlView.topAnchor.constraint(
                equalTo: sessionView.bottomAnchor, constant: controlViewTopDistance),
            controlView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controlView.heightAnchor.constraint(equalToConstant: controlViewHeight)
        ])
    }

    private func configureSessionView() {
        for round in 1 ... viewModel.sessionRounds {
            let imageView = UIImageView()
            if round < viewModel.presentRound {
                imageView.image = UIImage(systemName: "circle.filled")
            } else if round == viewModel.presentRound {
                imageView.image = UIImage(systemName: "circle.lefthalf.filled")
            } else {
                imageView.image = UIImage(systemName: "circle")
            }
            imageView.tintColor = .customInfoColor
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 18),
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1)
            ])
            sessionView.addArrangedSubview(imageView)
        }
    }

    @objc private func startTimer() {
        viewModel.startTimer()
    }

    @objc private func pauseTimer() {
        viewModel.pauseTimer()
    }

    @objc private func stopTimer() {
        viewModel.stopTimer()
    }
}
