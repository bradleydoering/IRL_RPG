//
//  Skill+Extensions.swift
//  IRL-RPG
//

import Foundation

extension Skill {
    var skillKind: SkillKind? {
        SkillKind(rawValue: kindRaw)
    }

    var category: SkillCategory {
        if let kind = skillKind {
            return kind.category
        }
        return SkillCategory(rawValue: categoryRaw) ?? .mind
    }

    var displayName: String {
        skillKind?.displayName ?? kindRaw.capitalized
    }

    var levelSubtitle: String {
        let xpValue = Int(xpTotal)
        let level = XPService.level(forTotalXp: xpValue)
        let progress = XPService.progressToNextLevel(forTotalXp: xpValue)
        let percent = Int((progress.percent * 100.0).rounded())
        return "Lv \(level) • \(xpValue) XP • \(percent)%"
    }
}

extension SkillCategory {
    var displayName: String {
        rawValue.capitalized
    }
}
