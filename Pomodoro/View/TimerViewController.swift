//
//  TimerViewController.swift
//  Pomodoro
//
//  Created by Riley Lai on 2023/1/5.
//

import UIKit

final class TimerViewController: UIViewController {

    private let timerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 58, weight: .semibold)
        label.textColor = .customInfoColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .semibold)
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
        button.setImage(UIImage(systemName: "play"), for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.addTarget(self, action: #selector(startTimer), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var pauseButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "pause"), for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.addTarget(self, action: #selector(pauseTimer), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var resumeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play"), for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.addTarget(self, action: #selector(startTimer), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var resetButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "backward.end"), for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.addTarget(self, action: #selector(resetRound), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let controlView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 36
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    let timerViewModel: TimerViewModel

    init(viewModel: TimerViewModel) {
        self.timerViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureViewModel()

        addTimerLifeCycleObserver()
    }

    private func configureViews() {
        view.backgroundColor = .customBackgroundColor
        [timerLabel, typeLabel, sessionView, startButton, pauseButton, controlView]
            .forEach { view.addSubview($0) }
        [resumeButton, resetButton]
            .forEach { controlView.addArrangedSubview($0) }
        controlView.subviews.forEach { $0.isHidden = true }
        updateSessionView()

        let controlViewHeight: CGFloat = 38
        let controlViewTopDistance: CGFloat = 28
        NSLayoutConstraint.activate([
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            typeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            typeLabel.bottomAnchor.constraint(equalTo: timerLabel.topAnchor, constant: -12),

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

            resetButton.heightAnchor.constraint(equalToConstant: controlViewHeight),
            resetButton.widthAnchor.constraint(equalTo: startButton.heightAnchor, multiplier: 1),

            pauseButton.heightAnchor.constraint(equalToConstant: controlViewHeight),
            pauseButton.widthAnchor.constraint(equalTo: startButton.heightAnchor, multiplier: 1),

            controlView.topAnchor.constraint(
                equalTo: sessionView.bottomAnchor, constant: controlViewTopDistance),
            controlView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controlView.heightAnchor.constraint(equalToConstant: controlViewHeight)
        ])
    }

    private func updateSessionView() {
        sessionView.subviews.forEach { $0.removeFromSuperview() }

        for index in 0 ..< timerViewModel.sessionImages.count {
            let imageView = UIImageView()
            imageView.image = timerViewModel.sessionImages[index]
            imageView.tintColor = .customInfoColor
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 18),
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1)
            ])

            sessionView.addArrangedSubview(imageView)
        }
    }

    private func configureViewModel() {
        timerViewModel.timeLabelBinder = { [weak self] timeLeftText in
            self?.timerLabel.text = timeLeftText
        }

        timerViewModel.countdownStateBinder = { [weak self] buttonsStates in
            guard let self = self else { return }
            self.startButton.isHidden = buttonsStates.startButtonShouldHide
            self.pauseButton.isHidden = buttonsStates.pauseButtonShouldHide
            self.controlView.subviews.forEach {
                $0.isHidden = buttonsStates.resumeAndResetButtonsShouldHide
            }

            self.updateSessionView()
        }

        timerViewModel.countdownTypeBinder = { [weak self] countdownType in
            self?.typeLabel.text = countdownType.title
        }
    }

    @objc private func startTimer() {
        timerViewModel.startTimer()
    }

    @objc private func pauseTimer() {
        timerViewModel.pauseTimer()
    }

    @objc private func resetRound() {
        timerViewModel.resetRound()
    }
}

extension TimerViewController: TimerLifeCycleController {}
