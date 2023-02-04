//
//  SettingsViewModel.swift
//  Pomodoro
//
//  Created by kgcoc on 2023/1/24.
//

import RxSwift
import Foundation
import CoreData

protocol FetchedResultsProviding: NSFetchedResultsControllerDelegate {
    associatedtype Object: NSManagedObject

    var context: NSManagedObjectContext { get }
    var fetchedResultsController: NSFetchedResultsController<Object> { get set }

}

extension FetchedResultsProviding {
    func performFetch() {
        try? fetchedResultsController.performFetch()
    }

    func updatePredicate(_ predicate: NSPredicate) {
        let fetchRequest = fetchedResultsController.fetchRequest
        fetchRequest.predicate = predicate
        performFetch()
    }

    func updateSortDescriptors(_ sortDescriptors: [NSSortDescriptor]) {
        let fetchRequest = fetchedResultsController.fetchRequest
        fetchRequest.sortDescriptors = sortDescriptors
        performFetch()
    }
}

class SettingsViewModel: NSObject, FetchedResultsProviding {

    let context: NSManagedObjectContext
    lazy var fetchedResultsController: NSFetchedResultsController<Rest> = {
        let fetchRequest = Rest.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Rest.startTimestamp, ascending: false)]
        fetchRequest.shouldRefreshRefetchedObjects = true

        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: storageProvider.persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        controller.delegate = self

        return controller
    }()

    var settingsValue = SettingsValue()
    var settingItems = PublishSubject<[SettingItem]>()
    var storageProvider: StorageProvider = StorageProvider.shared
    var items: [String: SettingItem] = [
        "flowDuration": SettingItem(
            item: .flowDuration(SettingsValue.flowDuration),
            settingCategory: .session,
            durations: SettingsValue.flowDuration),
        "breakDuration": SettingItem(
            item: .breakDuration(SettingsValue.breakDuration),
            settingCategory: .session,
            durations: SettingsValue.breakDuration),
        "autoStartBreak": SettingItem(
            item: .autoStartBreak,
            settingCategory: .session,
            isOn: SettingsValue.autoStartBreak),
        "autoStartFlow": SettingItem(
            item: .autoStartFlow,
            settingCategory: .session,
            isOn: SettingsValue.autoStartFlow),
        "notification": SettingItem(
            item: .notification,
            settingCategory: .general,
            isOn: SettingsValue.notification),
        "appleHealth": SettingItem(
            item: .appleHealth,
            settingCategory: .general,
            isOn: SettingsValue.appleHealth),
        "metronome": SettingItem(
            item: .metronome,
            settingCategory: .general,
            isOn: SettingsValue.metronome),
        "about": SettingItem(item: .about, settingCategory: .about),
        "how": SettingItem(item: .howToUse, settingCategory: .about),
        "reset": SettingItem(item: .reset, settingCategory: .reset)
    ]

    override init() {
        self.context = storageProvider.persistentContainer.viewContext
        super.init()
        fetchedResultsController.delegate = self
    }

    func fetchConfiguration() {
        var results: [SettingItem] = []
        Item.allCases.forEach { item in
            results.append(items[item.value]!)
        }
        settingItems.onNext(results)
    }

    func updateConfiguration<T>(item: Item, value: T) {
        switch item {
        case .flowDuration(_):
            let durations = value as! [Int]
            items[item.value]?.durations = value as! [Int]
            items[item.value]?.item = .flowDuration(durations)
            SettingsValue.setCloudKeyValue(propertyKey: item.value, value: value as! [Int])
        case .breakDuration(_):
            let durations = value as! [Int]
            items[item.value]?.durations = value as! [Int]
            items[item.value]?.item = .breakDuration(durations)
            SettingsValue.setCloudKeyValue(propertyKey: item.value, value: value as! [Int])
        default :
            print(item.value, value)
            items[item.value]?.isOn = value as! Bool
            SettingsValue.setCloudKeyValue(propertyKey: item.value, value: value as! Bool)
        }
    }

    func resetData() async throws {
        try storageProvider.resetReportData(resetObjects: ReportType.allCases)
    }
}
