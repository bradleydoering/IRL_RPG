//
//  XPService.swift
//  HumanSkillsRPG
//
//  Deterministic XP helpers built on GameRules.
//

import Foundation

struct XpBreakdown: Equatable {
    let baseXp: Int
    let streakMultiplier: Double
    let streakedXp: Int
    let bonusXp: Int
    let totalXp: Int
}

enum XPService {
    static func baseXp(skill: SkillKind, minutes: Int? = nil, sessions: Int = 1) -> Int {
        if skill.isTimeBased {
            let mins = minutes ?? 0
            return GameRules.baseXpForMinutes(mins, skill: skill)
        }
        return max(0, sessions) * skill.defaultSessionXp
    }

    static func streakMultiplier(for streakDays: Int) -> Double {
        GameRules.streakMultiplier(streakDays: streakDays)
    }

    static func applyStreak(baseXp: Int, streakDays: Int) -> Int {
        let multiplier = streakMultiplier(for: streakDays)
        return Int((Double(baseXp) * multiplier).rounded())
    }

    static func breakdown(baseXp: Int, streakDays: Int, bonusXp: Int) -> XpBreakdown {
        let multiplier = streakMultiplier(for: streakDays)
        let streaked = Int((Double(baseXp) * multiplier).rounded())
        let total = max(0, streaked + bonusXp)
        return XpBreakdown(baseXp: baseXp,
                           streakMultiplier: multiplier,
                           streakedXp: streaked,
                           bonusXp: bonusXp,
                           totalXp: total)
    }

    static func totalXpRequired(forLevel level: Int) -> Int {
        GameRules.totalXpRequired(forLevel: level)
    }

    static func level(forTotalXp xp: Int) -> Int {
        GameRules.level(forTotalXp: xp)
    }

    static func progressToNextLevel(forTotalXp xp: Int) -> (level: Int, currentLevelXp: Int, nextLevelXp: Int, percent: Double) {
        GameRules.progressToNextLevel(forTotalXp: xp)
    }
}
