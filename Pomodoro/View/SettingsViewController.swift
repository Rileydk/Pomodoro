//
//  SettingsViewController.swift
//  Pomodoro
//
//  Created by kgcoc on 2023/1/18.
//

//
//  SimpleListViewController.swift
//  PomodoTest
//
//  Created by kgcoc on 2023/1/19.
//

import UIKit
import RxSwift
import RxCocoa

class SettingsViewController: UIViewController {

    typealias SettingDataSource = UITableViewDiffableDataSource<SettingCategory, SettingItem>
    typealias SettingSnapshot = NSDiffableDataSourceSnapshot<SettingCategory, SettingItem>
    private var dataSource: SettingDataSource!

    let tableView = UITableView(frame: .zero, style: .insetGrouped)

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private var viewModel: SettingsViewModel

    static let reuseIdentifier = "reuse-identifier"

    init(viewModel: SettingsViewModel = SettingsViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true

        configureTableView()
        configureDataSource()
        bindTableView()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchConfiguration()
    }
}

extension SettingsViewController {

    func configureDataSource() {

        dataSource = SettingDataSource(tableView: tableView, cellProvider: { [weak self] tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: SettingsViewController.reuseIdentifier,
                for: indexPath)

            var content = cell.defaultContentConfiguration()
            content.text = itemIdentifier.item.description
            if let image = itemIdentifier.item.image {
                content.image = image
                content.imageProperties.tintColor = .systemIndigo
            }

            switch itemIdentifier.item.itemType {
            case .switchType:
                let enableSwitch = SettingSwitch()
                enableSwitch.item = itemIdentifier.item
                enableSwitch.isOn = itemIdentifier.isOn
                enableSwitch.addTarget(self, action: #selector(self!.toggleItem(_:)), for: .valueChanged)
                cell.accessoryView = enableSwitch
            case .plain:
                cell.accessoryView = nil
                content.textProperties.color = .red
            default:
                switch itemIdentifier.item {

                case .flowDuration(_), .breakDuration(_):
                    if itemIdentifier.durations.count > 0 {
                        content.secondaryText = itemIdentifier.timesString
                    }
                default:
                    print("")
                }

                cell.accessoryType = .disclosureIndicator
                cell.accessoryView = nil
            }
            cell.selectionStyle = .none
            cell.contentConfiguration = content
            return cell
        })

        self.dataSource.defaultRowAnimation = .fade
    }
}

extension SettingsViewController {

    func configureTableView() {
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.delegate = self

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: SettingsViewController.reuseIdentifier)
    }

    @objc func toggleItem(_ settingsEnabledSwitch: SettingSwitch) {
        if let settingItem = settingsEnabledSwitch.item {
            viewModel.updateConfiguration(item: settingItem, value: settingsEnabledSwitch.isOn)
        }
    }
}

extension SettingsViewController {
    func bindTableView() {
        viewModel.settingItems
            .withUnretained(self)
            .bind(onNext: { (vc, items) in

                var currentSnapshot = SettingSnapshot()

                currentSnapshot.appendSections(SettingCategory.allCases)

                SettingCategory.allCases.forEach { settingCategory in
                    currentSnapshot.appendItems(items.filter { $0.settingCategory == settingCategory }, toSection: settingCategory)
                }

                vc.dataSource.apply(currentSnapshot, animatingDifferences: false)
            })
            .disposed(by: disposeBag)
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if SettingCategory.allCases[indexPath.section] == .session {
            switch Item.allCases[indexPath.item] {
            case .flowDuration, .breakDuration:
                if let settingItem = viewModel.items[Item.allCases[indexPath.item].value],
                   let vc = settingItem.item.destVC as? DurationViewController {
                    vc.completion = { [unowned self] durations in
                        print("durations = ", durations)
                        if durations != [0, 0] && durations != [0] {
                            self.viewModel.updateConfiguration(item: settingItem.item, value: durations)
                        }
                    }
                    navigationController?.pushViewController(vc, animated: false)
                }

            default:
                break
            }
        } else if SettingCategory.allCases[indexPath.section] == .reset {
            do {
                Task { try await viewModel.resetData() }
            } catch {
                print("error ===")
            }
        }
    }
}

class SettingSwitch: UISwitch {
    var item: Item?
}
