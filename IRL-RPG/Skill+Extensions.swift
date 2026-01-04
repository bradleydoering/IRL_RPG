//
//  Skill+Extensions.swift
//  IRL-RPG
//

import Foundation

extension Skill {
    var skillKind: SkillKind? {
        guard let raw = kindRaw else { return nil }
        return SkillKind(rawValue: raw)
    }

    var category: SkillCategory {
        if let kind = skillKind {
            return kind.category
        }
        guard let raw = categoryRaw else { return .mind }
        return SkillCategory(rawValue: raw) ?? .mind
    }

    var displayName: String {
        if let kind = skillKind { return kind.displayName }
        return kindRaw?.capitalized ?? "Unknown"
    }

    var iconName: String {
        skillKind?.iconName ?? "circle"
    }

    var assetName: String {
        skillKind?.rawValue ?? ""
    }

    var levelSubtitle: String {
        let xpValue = Int(xpTotal)
        let level = XPService.level(forTotalXp: xpValue)
        let progress = XPService.progressToNextLevel(forTotalXp: xpValue)
        let percent = Int((progress.percent * 100.0).rounded())
        return "Lv \(level) • \(xpValue) XP • \(percent)%"
    }

    var levelValue: Int {
        XPService.level(forTotalXp: Int(xpTotal))
    }

    var xpValue: Int {
        Int(xpTotal)
    }

    var shortDescription: String {
        skillKind?.shortDescription ?? "Unknown skill."
    }

    var motivationalQuip: String {
        skillKind?.motivationalQuip ?? ""
    }

    var trackingDescription: String {
        skillKind?.trackingDescription ?? "Tracking unavailable."
    }

    var isLoggable: Bool {
        skillKind?.isLoggable ?? false
    }
}

extension SkillCategory {
    var displayName: String {
        rawValue.capitalized
    }
}
