//
//  StreakService.swift
//  HumanSkillsRPG
//
//  Streak update logic and restart detection.
//

import Foundation

struct StreakUpdate: Equatable {
    let currentStreakDays: Int
    let longestStreakDays: Int
    let isSameDay: Bool
    let didRestart: Bool
    let missedDays: Int
}

struct StreakService {
    let timeService: TimeService

    init(timeService: TimeService = TimeService()) {
        self.timeService = timeService
    }

    func updateStreak(lastTrainedDay: LocalDay?,
                      currentStreakDays: Int,
                      longestStreakDays: Int,
                      trainedDay: LocalDay) -> StreakUpdate {
        guard let last = lastTrainedDay else {
            return StreakUpdate(currentStreakDays: 1,
                                longestStreakDays: max(longestStreakDays, 1),
                                isSameDay: false,
                                didRestart: false,
                                missedDays: 0)
        }

        let dayGap = timeService.daysBetween(last, trainedDay)
        if dayGap == 0 {
            return StreakUpdate(currentStreakDays: currentStreakDays,
                                longestStreakDays: longestStreakDays,
                                isSameDay: true,
                                didRestart: false,
                                missedDays: 0)
        }

        if dayGap == 1 {
            let newCurrent = max(1, currentStreakDays + 1)
            let newLongest = max(longestStreakDays, newCurrent)
            return StreakUpdate(currentStreakDays: newCurrent,
                                longestStreakDays: newLongest,
                                isSameDay: false,
                                didRestart: false,
                                missedDays: 0)
        }

        let missed = max(0, dayGap - 1)
        return StreakUpdate(currentStreakDays: 1,
                            longestStreakDays: max(longestStreakDays, 1),
                            isSameDay: false,
                            didRestart: true,
                            missedDays: missed)
    }

    func isRestart(lastTrainedDay: LocalDay?, trainedDay: LocalDay) -> Bool {
        guard let last = lastTrainedDay else { return false }
        return timeService.daysBetween(last, trainedDay) >= 2
    }
}
