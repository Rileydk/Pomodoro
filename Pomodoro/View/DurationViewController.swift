//
//  DurationViewController.swift
//  Pomodoro
//
//  Created by kgcoc on 2023/1/24.
//

import UIKit

class DurationViewController: UIViewController {

    enum DurationType {
        case breakDuration
        case flowDuration

        var sectionNumber: Int {
            switch self {
            case .breakDuration:
                return 2
            case .flowDuration:
                return 1
            }
        }

        var title: String {
            switch self {
            case .breakDuration:
                return "Break Duration"
            case .flowDuration:
                return "Flow Duration"
            }
        }

        var duarationNumber: [Int] {
            switch self {
            case .breakDuration:
                return [2, 3]
            case .flowDuration:
                return [8]
            }
        }

        var sectionDescription: [String] {
            switch self {
            case .breakDuration:
                return ["Short Break", "Long Break"]
            case .flowDuration:
                return ["Flow"]
            }
        }
    }

    var durationType: DurationType = .flowDuration
    var durations: [Int] = [] {
        didSet {
            print("=======")
            setupSelectedCell()

        }
    }

    var completion: (([Int]) -> (Void))?
    var selectedRow: [IndexPath] = []

    let tableView = UITableView(frame: .zero, style: .insetGrouped)

    static let reuseIdentifier = "duration-reuse-identifier"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = durationType.title
        configureTableView()
        setupSelectedCell()

    }

    init(durationType: DurationType, item: Item) {
        self.durationType = durationType
        switch item {

        case .flowDuration(let durations), .breakDuration(let durations):
            self.durations = durations
        default:
            break
        }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupSelectedCell() {
        if durations != [0] && durations != [0, 0] {
            selectedRow.removeAll()
            durations.enumerated().forEach { index, duration in
                selectedRow.append(IndexPath(item: (duration/5)-1, section: index))
                print(selectedRow)
            }
        }
    }
}

extension DurationViewController {

    func configureTableView() {
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: DurationViewController.reuseIdentifier)
    }
}

extension DurationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        durationType.duarationNumber[section]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DurationViewController.reuseIdentifier, for: indexPath)
        var content = cell.defaultContentConfiguration()
        let currentValue = (indexPath.item + 1) * 5
        content.text = "\(currentValue) min"
        cell.contentConfiguration = content
        cell.selectionStyle = .none

        if [durations[indexPath.section]].contains(currentValue) {
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        durationType.sectionNumber
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        durationType.sectionDescription[section]
    }

}

extension DurationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        print(selectedRow[indexPath.section])
        if !selectedRow.isEmpty,
           let previousSelectedCell = tableView.cellForRow(at: selectedRow[indexPath.section]),
           previousSelectedCell != cell {
            cell!.accessoryType = .checkmark
            previousSelectedCell.accessoryType = .none
        }

        switch durationType {
        case .breakDuration:
            durations[indexPath.section] = (indexPath.item + 1) * 5
            self.completion?(durations)
        case .flowDuration:
            durations[indexPath.section] = (indexPath.item + 1) * 5
            self.completion?(durations)
        }
    }
}
