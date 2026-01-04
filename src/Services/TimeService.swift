//
//  TimeService.swift
//  HumanSkillsRPG
//
//  Local-day normalization and week-boundary helpers.
//

import Foundation

enum Weekday: Int, CaseIterable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
}

struct TimeService {
    private(set) var calendar: Calendar

    init(timeZone: TimeZone = .current, weekStart: Weekday = .monday) {
        var cal = Calendar.current
        cal.timeZone = timeZone
        cal.firstWeekday = weekStart.rawValue
        self.calendar = cal
    }

    func localDay(for date: Date) -> LocalDay {
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        return LocalDay(year: comps.year ?? 1970,
                        month: comps.month ?? 1,
                        day: comps.day ?? 1)
    }

    func date(for localDay: LocalDay) -> Date {
        let comps = DateComponents(year: localDay.year, month: localDay.month, day: localDay.day)
        return calendar.date(from: comps) ?? Date(timeIntervalSince1970: 0)
    }

    func startOfDay(for localDay: LocalDay) -> Date {
        calendar.startOfDay(for: date(for: localDay))
    }

    func addDays(_ day: LocalDay, days: Int) -> LocalDay {
        let base = date(for: day)
        let next = calendar.date(byAdding: .day, value: days, to: base) ?? base
        return self.localDay(for: next)
    }

    func daysBetween(_ start: LocalDay, _ end: LocalDay) -> Int {
        let startDate = startOfDay(for: start)
        let endDate = startOfDay(for: end)
        let comps = calendar.dateComponents([.day], from: startDate, to: endDate)
        return comps.day ?? 0
    }

    func weekStart(for day: LocalDay) -> LocalDay {
        let dateValue = date(for: day)
        let weekday = calendar.component(.weekday, from: dateValue)
        let delta = (weekday - calendar.firstWeekday + 7) % 7
        let startDate = calendar.date(byAdding: .day, value: -delta, to: dateValue) ?? dateValue
        return self.localDay(for: startDate)
    }
}
