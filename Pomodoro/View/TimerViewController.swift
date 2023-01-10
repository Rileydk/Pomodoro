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
        label.text = "25:00"
        label.font = UIFont.systemFont(ofSize: 58, weight: .semibold)
        label.textColor = .customInfoColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let sessionView: UIStackView = {
        let stackView = UIStackView()

        for _ in 1 ... 4 {
            let imageView = UIImageView()
            imageView.image = UIImage(systemName: "circle.lefthalf.filled")
            imageView.tintColor = .customInfoColor
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 18),
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1)
            ])
            stackView.addArrangedSubview(imageView)
        }

        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let startButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let pauseButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let stopButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "gobackward"), for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let controlView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 22
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }

    private func configureViews() {
        view.backgroundColor = .customBackgroundColor
        [timerLabel, sessionView, startButton, controlView].forEach { view.addSubview($0) }
        [pauseButton, stopButton].forEach { controlView.addArrangedSubview($0) }
        controlView.subviews.forEach { $0.isHidden = true }

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
}
