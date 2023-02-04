//
//  StorageProvider+AddRecord.swift
//  Pomodoro
//
//  Created by kgcoc on 2023/1/28.
//

import CoreData
import CloudKit

extension StorageProvider {

    enum RecordType {
        case rest
        case focus
    }

    private func genDataComponents(
        startTimestamp: Date,
        endTimestamp: Date
    ) -> (DateComponents, DetailRecord) {
        let startLocalTimestamp = startTimestamp.localDate()
        let startComponents = startTimestamp.customDateComponents()
        let endComponents = endTimestamp.customDateComponents()
        let startLocalComponents = startLocalTimestamp.customDateComponents()
        let durationMinutes = startComponents.dateInterval(toDateComponents: endComponents)

        let detailRecord = DetailRecord(
            startTimestamp: startTimestamp,
            endTimestamp: endTimestamp,
            startLocalTimestamp: startLocalTimestamp,
            startYear: Int16(startLocalComponents.year!),
            startMonth: Int16(startLocalComponents.month!),
            startWeekOfYear: Int16(startLocalComponents.weekOfYear!),
            startDay: Int16(startLocalComponents.day!),
            durationMinutes: durationMinutes
        )

        return (startLocalComponents, detailRecord)
    }

    private func addRestRecord(
        context: NSManagedObjectContext,
        startLocalComponents: DateComponents,
        detailRecord: DetailRecord
    ) async throws {
        try context.performAndWait {
            let record = Rest(context: context)
            record.startTimestamp = detailRecord.startTimestamp
            record.endTimestamp = detailRecord.endTimestamp
            record.startYear = detailRecord.startYear
            record.startMonth = detailRecord.startMonth
            record.startWeekOfYear = detailRecord.startWeekOfYear
            record.startDay = detailRecord.startDay
            record.durationMinutes = detailRecord.durationMinutes

            try context.save()
        }
    }

    private func addFocusRecord(
        context: NSManagedObjectContext,
        startLocalComponents: DateComponents,
        detailRecord: DetailRecord
    ) async throws {
        try context.performAndWait {
            let record = Focus(context: context)
            record.startTimestamp = detailRecord.startTimestamp
            record.endTimestamp = detailRecord.endTimestamp
            record.startYear = detailRecord.startYear
            record.startMonth = detailRecord.startMonth
            record.startWeekOfYear = detailRecord.startWeekOfYear
            record.startDay = detailRecord.startDay
            record.durationMinutes = detailRecord.durationMinutes

            try context.save()
        }
    }

    func addRecord(
        startTimestamp: Date,
        endTimestamp: Date,
        recordType: RecordType,
        context: NSManagedObjectContext? = nil
    ) async throws {
        let context = context ?? newTaskContext()
        let (startLocalComponents, detailRecord) = genDataComponents(
            startTimestamp: startTimestamp,
            endTimestamp: endTimestamp
        )

        switch recordType {
        case .rest:
            try await addRestRecord(
                context: context,
                startLocalComponents: startLocalComponents,
                detailRecord: detailRecord
            )
        case .focus:
            try await addFocusRecord(
                context: context,
                startLocalComponents: startLocalComponents,
                detailRecord: detailRecord
            )
        }
        // report
        await upsertDailyReport(
            startComponents: startLocalComponents,
            detailRecord: detailRecord,
            recordType: recordType,
            context: context)
        await upsertWeekReport(
            startComponents: startLocalComponents,
            detailRecord: detailRecord,
            recordType: recordType,
            context: context)
        await upsertMonthlyReport(
            startComponents: startLocalComponents,
            detailRecord: detailRecord,
            recordType: recordType,
            context: context)
    }

    func upsertMonthlyReport(
        startComponents: DateComponents,
        detailRecord: DetailRecord,
        recordType: RecordType,
        context: NSManagedObjectContext? = nil
    ) async {
        let context = context ?? newTaskContext()

        let fetchRequest = MonthlyReport.fetchRequest()
        fetchRequest.predicate = dateFilter(dateComponents: startComponents, reportType: .monthly)

        do {
            let records = try context.fetch(fetchRequest)
            if records.isEmpty {
                let monthlyReport = MonthlyReport(context: context)
                monthlyReport.month = detailRecord.startMonth
                monthlyReport.year = detailRecord.startYear
                monthlyReport.date = detailRecord.startLocalTimestamp.startOfMonth()
                switch recordType {
                case .rest:
                    monthlyReport.restTotal = detailRecord.durationMinutes
                case .focus:
                    monthlyReport.focusTotal = detailRecord.durationMinutes
                }
            } else {
                guard
                    let record = records.first,
                    let item = try context.existingObject(with: record.objectID) as? MonthlyReport else {
                    throw CoreDataError.notFound
                }
                switch recordType {
                case .rest:
                    item.restTotal += detailRecord.durationMinutes
                case .focus:
                    item.focusTotal += detailRecord.durationMinutes
                }
            }
            try context.save()

        } catch {
            print(error)
        }
    }

    func upsertWeekReport(
        startComponents: DateComponents,
        detailRecord: DetailRecord,
        recordType: RecordType,
        context: NSManagedObjectContext? = nil
    ) async {
        let context = context ?? newTaskContext()

        let fetchRequest = WeeklyReport.fetchRequest()
        fetchRequest.predicate = dateFilter(dateComponents: startComponents, reportType: .weekly)

        do {
            let records = try context.fetch(fetchRequest)
            if records.isEmpty {
                let weeklyReport = WeeklyReport(context: context)
                weeklyReport.weekOfYear = detailRecord.startWeekOfYear
                weeklyReport.year = detailRecord.startYear
                weeklyReport.month = detailRecord.startMonth
                weeklyReport.date = detailRecord.startLocalTimestamp.startOfWeek()
                switch recordType {
                case .rest:
                    weeklyReport.restTotal = detailRecord.durationMinutes
                case .focus:
                    weeklyReport.focusTotal = detailRecord.durationMinutes
                }
            } else {
                guard
                    let record = records.first,
                    let item = try context.existingObject(with: record.objectID) as? WeeklyReport else {
                    throw CoreDataError.notFound
                }
                switch recordType {
                case .rest:
                    item.restTotal += detailRecord.durationMinutes
                case .focus:
                    item.focusTotal += detailRecord.durationMinutes
                }
            }
            try context.save()

        } catch {
            print(error)
        }
    }

    func upsertDailyReport(
        startComponents: DateComponents,
        detailRecord: DetailRecord,
        recordType: RecordType,
        context: NSManagedObjectContext? = nil
    ) async {
        let context = context ?? newTaskContext()

        let fetchRequest = DailyReport.fetchRequest()
        fetchRequest.predicate = dateFilter(dateComponents: startComponents, reportType: .daily)

        do {
            let records = try context.fetch(fetchRequest)
            if records.isEmpty {
                let dailyRecord = DailyReport(context: context)
                dailyRecord.dayOfMonth = detailRecord.startDay
                dailyRecord.month = detailRecord.startMonth
                dailyRecord.weekOfYear = detailRecord.startWeekOfYear
                dailyRecord.year = detailRecord.startYear
                dailyRecord.date = detailRecord.startLocalTimestamp

                switch recordType {
                case .rest:
                    dailyRecord.restTotal = detailRecord.durationMinutes
                case .focus:
                    dailyRecord.focusTotal = detailRecord.durationMinutes
                }
            } else {
                guard
                    let record = records.first,
                    let item = try context.existingObject(with: record.objectID) as? DailyReport else {
                    throw CoreDataError.notFound
                }
                switch recordType {
                case .rest:
                    item.restTotal += detailRecord.durationMinutes
                case .focus:
                    item.focusTotal += detailRecord.durationMinutes
                }
            }
            try context.save()

        } catch {
            print(error)
        }
    }

    private func resetReportData(reportType: ReportType) throws {
        // raw
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
        fetchRequest = NSFetchRequest(entityName: reportType.entityName)

        let deleteRequest = NSBatchDeleteRequest(
            fetchRequest: fetchRequest
        )

        deleteRequest.resultType = .resultTypeObjectIDs

        let context = persistentContainer.viewContext

        let batchDelete = try context.execute(deleteRequest) as? NSBatchDeleteResult

        guard let deleteResult = batchDelete?.result as? [NSManagedObjectID] else { return }

        let deletedObjects: [AnyHashable: Any] = [
            NSDeletedObjectsKey: deleteResult
        ]

        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: deletedObjects,
            into: [context]
        )
    }

    func resetReportData(resetObjects: [ReportType]) throws {
        try resetObjects.forEach { reportType in
            try resetReportData(reportType: reportType)
        }
    }
}

extension StorageProvider {
    func dateFilter(dateComponents: DateComponents, reportType: ReportType) -> NSPredicate {
        switch reportType {
        case .weekly:
            return NSPredicate(
                format: "year = %d and weekOfYear = %d",
                dateComponents.year!,
                dateComponents.weekOfYear!
            )
        case .monthly:
            return  NSPredicate(
                format: "(year = %d) AND (month = %d)",
                dateComponents.year!,
                dateComponents.month!
            )
        case .daily:
            return NSPredicate(
                format: "year = %d and month = %d and dayOfMonth = %d",
                dateComponents.year!,
                dateComponents.month!,
                dateComponents.day!
            )
        case .focus, .rest:
            return NSPredicate(
                format: "(startYear = %d) AND (startMonth = %d) AND (startDay = %d)",
                dateComponents.year!,
                dateComponents.month!,
                dateComponents.day!
            )
        }
    }
}
