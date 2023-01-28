//
//  StorageProvider.swift
//  Pomodoro
//
//  Created by kgcoc on 2023/1/25.
//

import CoreData
import CloudKit

enum AppIdentifier {
    static let coreDataModel = "Pomodoro"
    static let cloudKitContainer = "iCloud.com.rileylai.Pomodoro"
}

class StorageProvider {
    static let shared = StorageProvider()

    lazy var cloudKitContainer = CKContainer(identifier: AppIdentifier.cloudKitContainer)

    let persistentContainer: NSPersistentCloudKitContainer

    private var _privatePersistentStore: NSPersistentStore!

    var privatePersistentStore: NSPersistentStore {
        return _privatePersistentStore
    }

    private init() {
        self.persistentContainer = NSPersistentCloudKitContainer(name: AppIdentifier.coreDataModel)
        configurePersistentContainer()
    }

    private func configurePersistentContainer() {
        persistentContainer.persistentStoreDescriptions = createStoreDescriptions()

        persistentContainer.loadPersistentStores {[unowned self] storeDescription, error in
            if let error = error as NSError? {
                fatalError("#\(#function): Failed to load persistent stores: \(error), \(error.userInfo)")
            }

            guard
                let cloudKitContainerOptions = storeDescription.cloudKitContainerOptions,
                let storeURL = storeDescription.url
            else {
                return
            }

            _privatePersistentStore = persistentContainer.persistentStoreCoordinator.persistentStore(for: storeURL)

            print("#\(#function): Load persistent store", storeDescription)
        }

        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        do {
            try persistentContainer.viewContext.setQueryGenerationFrom(.current)
        } catch {
            fatalError("#\(#function): Failed to pin viewContext to the current generation:\(error)")
        }
    }

    private func initializeCloudKitSchema() {
        do {
            try persistentContainer.initializeCloudKitSchema()
        } catch {
            print("\(#function): initializeCloudKitSchema: \(error)")
        }
    }

    private func createStoreDescriptions() -> [NSPersistentStoreDescription] {
        guard let storeDescription = persistentContainer.persistentStoreDescriptions.first else {
            fatalError("#\(#function): Failed to retrieve a persistent store description.")
        }

        storeDescription.setOption(
            true as NSNumber,
            forKey: NSPersistentHistoryTrackingKey)

        storeDescription.setOption(
            true as NSNumber,
            forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        let storeOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: AppIdentifier.cloudKitContainer
        )

        storeOptions.databaseScope = .private
        storeDescription.cloudKitContainerOptions = storeOptions

        return [storeDescription]
    }

    func newTaskContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    func mergeTransactions(_ transactions: [NSPersistentHistoryTransaction], to context: NSManagedObjectContext) {
        context.perform {
            transactions.forEach { context.mergeChanges(fromContextDidSave: $0.objectIDNotification()) }
        }
    }
}


//enum Result {
//    case Rest(Rest)
//    case Focus(Focus)
//    case MonthlyReport(MonthlyReport)
//    case weeklyReport(WeeklyReport)
//    case none
//}
//
//func make(context: NSManagedObjectContext, recordType: RecordType) -> Result {
//    switch recordType {
//    case .rest:
//        return .Rest(Rest(context: context))
//    case .focus:
//        return .Focus(Focus(context: context))
//    case .monthlyReport:
//        return .MonthlyReport(MonthlyReport(context: context))
//    case .weeklyReport:
//        return .weeklyReport(WeeklyReport(context: context))
//    }
//}

enum CoreDataError: Error {
    case notFound
}


