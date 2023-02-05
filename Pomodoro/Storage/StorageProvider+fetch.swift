//
//  StorageProvider+fetch.swift
//  Pomodoro
//
//  Created by kgcoc on 2023/1/28.
//

import Foundation
import CoreData
extension StorageProvider {

    private func fetchRestRecords(requestDate: Date) async throws -> [DetailRecord] {
        let localDateComponents = requestDate.localDate().customDateComponents()

        let context = persistentContainer.viewContext
        let fetchRequest = Rest.fetchRequest()
        fetchRequest.predicate = dateFilter(dateComponents: localDateComponents, reportType: .rest)

        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Rest.startTimestamp, ascending: false)]

        let results = try context.fetch(fetchRequest) as [Rest]

        let records = results.map { DetailRecord(record: $0) }

        return records
    }

    private func fetchFocusRecords(requestDate: Date) async throws -> [DetailRecord] {
        let localDateComponents = requestDate.localDate().customDateComponents()

        let context = persistentContainer.viewContext
        let fetchRequest = Focus.fetchRequest()
        fetchRequest.predicate = dateFilter(dateComponents: localDateComponents, reportType: .focus)

        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Focus.startTimestamp, ascending: false)]

        let results = try context.fetch(fetchRequest) as [Focus]

        let records = results.map { DetailRecord(record: $0) }

        return records
    }

    func fetchData<T>(
        entity: T.Type,
        requestDate: Date
    ) async throws -> [DetailRecord] where T: RestFocus, T: NSManagedObject {

        let localDateComponents = requestDate.localDate().customDateComponents()

        let context = persistentContainer.viewContext
        let fetchRequest = T.fetchRequest()
        fetchRequest.predicate = dateFilter(dateComponents: localDateComponents, reportType: .focus)

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startTimestamp", ascending: false)]

        let results = try context.fetch(fetchRequest) as! [Focus]

        let records = results.map { DetailRecord(record: $0) }

        return records
    }

    func fetchDetailTimeByDay(requestDate: Date, recordType: RecordType) async throws -> [DetailRecord] {
        if recordType == .rest {
            return try await fetchRestRecords(requestDate: requestDate)
        } else {
            return try await fetchFocusRecords(requestDate: requestDate)
        }
    }

    func fetchWeeklyRecordByWeek(requestDate: Date, reportType: ReportType) async throws -> [ReportRecord] {
        let requestDC = requestDate.localDate().customDateComponents()
        let context = persistentContainer.viewContext

        let fetchRequest = WeeklyReport.fetchRequest()

        switch reportType {
        case .monthly:
            fetchRequest.predicate = dateFilter(dateComponents: requestDC, reportType: .monthly)
        case .weekly:
            fetchRequest.predicate = dateFilter(dateComponents: requestDC, reportType: .weekly)
        default:
            break
        }

        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \WeeklyReport.date, ascending: false)
        ]

        let results = try context.fetch(fetchRequest) as [WeeklyReport]

        let records = results.map { ReportRecord(weeklyReport: $0) }

        return records
    }

    func fetchMonthlyRecord(requestDate: Date, reportType: ReportType) async throws -> [ReportRecord] {
        let requestDC = requestDate.localDate().customDateComponents()
        let context = persistentContainer.viewContext

        let fetchRequest = MonthlyReport.fetchRequest()
        fetchRequest.predicate = dateFilter(dateComponents: requestDC, reportType: .monthly)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \MonthlyReport.date, ascending: false)
        ]

        let results = try context.fetch(fetchRequest) as [MonthlyReport]

        let records = results.map { ReportRecord(monthlyReport: $0) }

        return records
    }

    func fetchDailyReport(requestDate: Date, reportType: ReportType) async throws -> [ReportRecord] {
        let requestDC = requestDate.localDate().customDateComponents()
        let context = persistentContainer.viewContext

        let fetchRequest = DailyReport.fetchRequest()

        switch reportType {
        case .monthly:
            fetchRequest.predicate = dateFilter(dateComponents: requestDC, reportType: .monthly)
        case .weekly:
            fetchRequest.predicate = dateFilter(dateComponents: requestDC, reportType: .weekly)
        default:
            break
        }

        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \DailyReport.date, ascending: false)
        ]

        let results = try context.fetch(fetchRequest) as [DailyReport]

        let records = results.map { ReportRecord(dailyReport: $0) }

        return records
    }
}
