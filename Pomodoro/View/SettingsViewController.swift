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
    private var viewModel = SettingsViewModel()

    static let reuseIdentifier = "reuse-identifier"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Settings"

        configureTableView()
        configureDataSource()
        bindTableView()
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
                enableSwitch.addTarget(self, action: #selector(self!.toggleItem(_:)), for: .touchUpInside)
                cell.accessoryView = enableSwitch
            case .plain:
                cell.accessoryView = nil
                content.textProperties.color = .red
            default:
                switch itemIdentifier.item {

                case .flowPeriod(_), .restPeriod(_):
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

    @objc func toggleItem(_ wifiEnabledSwitch: UISwitch) {
        //        updateUI()
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

                vc.dataSource.apply(currentSnapshot, animatingDifferences: true)
            })
            .disposed(by: disposeBag)
        viewModel.fetchConfiguration()
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if SettingCategory.allCases[indexPath.section] == .session {
            let item = viewModel.items[Item.allCases[indexPath.item].value]
            switch Item.allCases[indexPath.item] {
            case .flowPeriod, .restPeriod:
                print(indexPath, SettingCategory.allCases[indexPath.section], Item.allCases[indexPath.item])
                navigationController?.pushViewController((item?.item.destVC!)!, animated: false)
            default:
                break
            }
        }
    }
}

class SettingSwitch: UISwitch {
    var item: Item?
}
