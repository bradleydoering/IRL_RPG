//
//  Models.swift
//  HumanSkillsRPG
//
//  Generated from game spec (v1)
//  Local-first models intended to back Core Data or SQLite persistence.
//  Keep game rules in pure functions for testability.
//

import Foundation

// MARK: - Skill Kind / Category

enum SkillCategory: String, Codable, CaseIterable {
    case mind
    case body
    case hobby
    case meta
}

enum SkillKind: String, Codable, CaseIterable, Identifiable {
    // Mind
    case reading
    case writing
    case research
    case deepWork
    case meditation

    // Body
    case weightlifting
    case cardio
    case walking
    case sleep
    case yoga
    case surfing
    case basketball
    case swimming
    case sauna
    case iceBaths

    // Hobby
    case woodworking
    case pottery
    case cooking
    case coding
    case drawing
    case painting
    case music
    case crafting

    // Meta
    case consistency
    case discipline
    case resilience
    case curiosity
    case creativity

    var id: String { rawValue }

    var category: SkillCategory {
        switch self {
        case .reading, .writing, .research, .deepWork, .meditation:
            return .mind
        case .weightlifting, .cardio, .walking, .sleep, .yoga, .surfing, .basketball, .swimming, .sauna, .iceBaths:
            return .body
        case .woodworking, .pottery, .cooking, .coding, .drawing, .painting, .music, .crafting:
            return .hobby
        case .consistency, .discipline, .resilience, .curiosity, .creativity:
            return .meta
        }
    }

    var displayName: String {
        switch self {
        case .deepWork: return "Deep Work"
        case .iceBaths: return "Ice Baths"
        default:
            return rawValue
                .replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression)
                .capitalized
        }
    }

    /// Whether the skill is primarily logged by minutes (timer) rather than discrete sessions.
    var isTimeBased: Bool {
        switch self {
        case .weightlifting, .woodworking, .pottery, .cooking, .crafting, .surfing, .basketball, .sauna, .iceBaths:
            return false // default session-based
        case .sleep:
            return true // passive minutes
        case .consistency, .discipline, .resilience, .curiosity:
            return false // derived; not directly time-based
        default:
            return true
        }
    }

    /// Default session XP for session-based skills (tunable).
    var defaultSessionXp: Int {
        switch self {
        case .weightlifting: return 400
        case .surfing: return 450
        case .basketball: return 400
        case .sauna: return 300
        case .iceBaths: return 300
        case .woodworking: return 400
        case .pottery: return 400
        case .cooking: return 350
        case .crafting: return 350
        default:
            return 400
        }
    }

    var iconName: String {
        switch self {
        case .reading: return "book.closed"
        case .writing: return "pencil.and.outline"
        case .research: return "graduationcap"
        case .deepWork: return "brain.head.profile"
        case .meditation: return "sparkles"
        case .weightlifting: return "dumbbell"
        case .cardio: return "heart.fill"
        case .walking: return "figure.walk"
        case .sleep: return "bed.double"
        case .yoga: return "figure.mind.and.body"
        case .surfing: return "wave.3.right"
        case .basketball: return "basketball"
        case .swimming: return "drop"
        case .sauna: return "flame"
        case .iceBaths: return "snowflake"
        case .woodworking: return "hammer"
        case .pottery: return "circle.hexagongrid"
        case .cooking: return "fork.knife"
        case .coding: return "chevron.left.slash.chevron.right"
        case .drawing: return "pencil.tip"
        case .painting: return "paintbrush"
        case .music: return "music.note"
        case .crafting: return "scissors"
        case .consistency: return "checkmark.seal"
        case .discipline: return "shield"
        case .resilience: return "arrow.clockwise"
        case .curiosity: return "questionmark.circle"
        case .creativity: return "sparkles"
        }
    }

    var shortDescription: String {
        switch self {
        case .reading: return "Books are portals. Read with purpose and return wiser."
        case .writing: return "Words sharpen thought. Put them to the page."
        case .research: return "Seek the hidden thread; study until the map is yours."
        case .deepWork: return "Silence the noise and forge your focus."
        case .meditation: return "Breathe. Stillness is a skill, not a mood."
        case .weightlifting: return "Raise iron, build will, earn your strength."
        case .cardio: return "Keep the heart’s drumbeat steady and bold."
        case .walking: return "A humble stride can carry mighty change."
        case .sleep: return "Rest is the forge where power is renewed."
        case .yoga: return "Balance and breath bend you toward calm."
        case .surfing: return "Ride the edge of the wave and learn its timing."
        case .basketball: return "Feet, hands, and heart in one swift rhythm."
        case .swimming: return "Water yields to the patient and the strong."
        case .sauna: return "Heat tempers; endure and emerge steadier."
        case .iceBaths: return "Cold reveals resolve. Hold fast."
        case .woodworking: return "Shape raw timber into something that lasts."
        case .pottery: return "Spin the wheel and shape the earth’s patience."
        case .cooking: return "Turn simple into sustaining with flame and care."
        case .coding: return "Craft logic into tools that move the world."
        case .drawing: return "Learn to see, then let your hand speak."
        case .painting: return "Color is memory; lay it down boldly."
        case .music: return "Practice until silence becomes song."
        case .crafting: return "Make with your hands; make it real."
        case .consistency: return "Small steps, many days, a steadfast path."
        case .discipline: return "When comfort calls, choose the climb."
        case .resilience: return "Fall, rise, and count the rising."
        case .curiosity: return "Follow the question; it always knows the way."
        case .creativity: return "Hobby sparks kindle this flame."
        }
    }

    var trackingDescription: String {
        if category == .meta {
            return "Auto-tracked based on related skills."
        }
        if isTimeBased {
            if self == .sleep {
                return "Time-based. Log minutes slept."
            }
            return "Time-based. Log minutes spent."
        }
        return "Session-based. Log each completed session."
    }

    var motivationalQuip: String {
        switch self {
        case .reading: return "Turn another page, adventurer."
        case .writing: return "Leave ink where doubt once stood."
        case .research: return "Truth favors the persistent."
        case .deepWork: return "Guard your focus like a treasure."
        case .meditation: return "The mind obeys a practiced breath."
        case .weightlifting: return "Strength is earned, rep by rep."
        case .cardio: return "Keep the pace; the miles add up."
        case .walking: return "One step can start a quest."
        case .sleep: return "Rest well; tomorrow needs you."
        case .yoga: return "Find the line between effort and ease."
        case .surfing: return "Wait for the wave, then commit."
        case .basketball: return "Play the moment, not the doubt."
        case .swimming: return "Glide, breathe, repeat."
        case .sauna: return "Stay with the heat."
        case .iceBaths: return "Cold now, calm later."
        case .woodworking: return "Measure twice, carve once."
        case .pottery: return "Let the clay teach patience."
        case .cooking: return "Stoke the fire; feed the future."
        case .coding: return "Ship the idea, then refine it."
        case .drawing: return "A line today becomes art tomorrow."
        case .painting: return "Color speaks when words do not."
        case .music: return "Practice until the note rings true."
        case .crafting: return "Make something that was not."
        case .consistency: return "Return again; that is the path."
        case .discipline: return "Choose the hard thing, then do it."
        case .resilience: return "You are the comeback."
        case .curiosity: return "Ask one more question."
        case .creativity: return "Play often; wonder follows."
        }
    }

    var isLoggable: Bool {
        category != .meta
    }
}

// MARK: - Local Day

/// A normalized local day representation for streak/quest logic.
struct LocalDay: Hashable, Codable, Comparable {
    let year: Int
    let month: Int
    let day: Int

    static func < (lhs: LocalDay, rhs: LocalDay) -> Bool {
        if lhs.year != rhs.year { return lhs.year < rhs.year }
        if lhs.month != rhs.month { return lhs.month < rhs.month }
        return lhs.day < rhs.day
    }
}

// MARK: - Core State Models (persist these)

struct SkillState: Identifiable, Codable {
    let id: UUID
    var kind: SkillKind

    // Progress
    var xpTotal: Int

    // Streak
    var currentStreakDays: Int
    var longestStreakDays: Int
    var lastTrainedDay: LocalDay?

    // Metadata
    var createdAt: Date
    var updatedAt: Date

    init(kind: SkillKind) {
        self.id = UUID()
        self.kind = kind
        self.xpTotal = 0
        self.currentStreakDays = 0
        self.longestStreakDays = 0
        self.lastTrainedDay = nil
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum SessionSource: String, Codable {
    case manual
    case timer
    case importHealth
    case importOura
}

struct SessionLog: Identifiable, Codable {
    let id: UUID
    var skillKind: SkillKind

    var startAt: Date?
    var endAt: Date?
    var durationSeconds: Int

    var baseXpAwarded: Int
    var streakMultiplierApplied: Double
    var bonusXpAwarded: Int
    var totalXpAwarded: Int

    var trainedDespiteResistance: Bool
    var source: SessionSource

    var createdAt: Date

    init(skillKind: SkillKind,
         durationSeconds: Int,
         baseXpAwarded: Int,
         streakMultiplierApplied: Double,
         bonusXpAwarded: Int,
         trainedDespiteResistance: Bool,
         source: SessionSource) {
        self.id = UUID()
        self.skillKind = skillKind
        self.startAt = nil
        self.endAt = nil
        self.durationSeconds = durationSeconds
        self.baseXpAwarded = baseXpAwarded
        self.streakMultiplierApplied = streakMultiplierApplied
        self.bonusXpAwarded = bonusXpAwarded
        self.totalXpAwarded = Int((Double(baseXpAwarded) * streakMultiplierApplied).rounded()) + bonusXpAwarded
        self.trainedDespiteResistance = trainedDespiteResistance
        self.source = source
        self.createdAt = Date()
    }
}

enum XpEventType: String, Codable {
    case base
    case dailyQuestBonus
    case weeklyQuestBonus
    case discipline
    case resilience
    case curiosity
    case creativity
    case manualAdjust
}

struct XpEvent: Identifiable, Codable {
    let id: UUID
    var at: Date
    var skillKind: SkillKind? // nil allowed for global meta events; usually set
    var type: XpEventType
    var amount: Int
    var note: String?

    init(skillKind: SkillKind?, type: XpEventType, amount: Int, note: String? = nil, at: Date = Date()) {
        self.id = UUID()
        self.at = at
        self.skillKind = skillKind
        self.type = type
        self.amount = amount
        self.note = note
    }
}

// MARK: - Quests

enum QuestRequirementType: String, Codable {
    case minutes
    case session
}

struct DailyQuest: Identifiable, Codable {
    let id: UUID
    var day: LocalDay
    var skillKind: SkillKind
    var requirementType: QuestRequirementType
    var requirementValue: Int // minutes or session count
    var completedAt: Date?
    var rewardsGranted: Bool

    init(day: LocalDay, skillKind: SkillKind, requirementType: QuestRequirementType, requirementValue: Int) {
        self.id = UUID()
        self.day = day
        self.skillKind = skillKind
        self.requirementType = requirementType
        self.requirementValue = requirementValue
        self.completedAt = nil
        self.rewardsGranted = false
    }
}

enum WeeklyQuestTemplate: String, Codable, CaseIterable {
    case balance
    case mindBody
    case focusedGrind
    case creativeBurst
    case comebackWeek
}

/// Keep progress flexible by storing template-specific counters.
struct WeeklyQuest: Identifiable, Codable {
    let id: UUID
    var weekStart: LocalDay
    var template: WeeklyQuestTemplate

    /// Template-specific progress values (e.g., "mindSessions": 2).
    var progress: [String: Int]

    /// Template-specific flags (e.g., which skills were used).
    var flags: [String: Bool]

    var completedAt: Date?
    var rewardsGranted: Bool

    init(weekStart: LocalDay, template: WeeklyQuestTemplate) {
        self.id = UUID()
        self.weekStart = weekStart
        self.template = template
        self.progress = [:]
        self.flags = [:]
        self.completedAt = nil
        self.rewardsGranted = false
    }
}

// MARK: - Game Rules (Pure Functions)

enum GameRules {
    // XP curve constants
    static let levelCurveA: Double = 120.0
    static let levelCurveB: Double = 2.2
    static let maxLevel: Int = 99

    // Base rates
    static let timeXpPerMinute: Int = 10
    static let sleepXpPerMinute: Int = 2

    // Daily quest rewards
    static let dailyQuestSkillBonusXp: Int = 200
    static let dailyQuestConsistencyXp: Int = 75

    // Discipline reward
    static let disciplineXpPerFlag: Int = 150

    // Resilience tiers (rolling 30 days)
    static func resilienceXp(forRestartCount restartCount: Int) -> Int {
        switch restartCount {
        case 1: return 300
        case 2: return 450
        case 3: return 600
        case 4: return 750
        default: return 900 // cap for 5+
        }
    }

    // Curiosity reward
    static let curiosityXpReward: Int = 200

    // Creativity reward from hobby activities (fraction of base XP).
    static let creativityHobbyXpMultiplier: Double = 0.2

    // Streak multiplier (hard capped)
    static func streakMultiplier(streakDays: Int) -> Double {
        switch streakDays {
        case 0, 1, 2: return 1.0
        case 3...6: return 1.1
        case 7...13: return 1.25
        case 14...29: return 1.4
        default: return 1.5
        }
    }

    /// Total XP required to reach a given level.
    static func totalXpRequired(forLevel level: Int) -> Int {
        guard level > 0 else { return 0 }
        let v = levelCurveA * pow(Double(level), levelCurveB)
        return Int(v.rounded(.toNearestOrEven))
    }

    /// Compute level from total XP using binary search (1..99).
    static func level(forTotalXp xp: Int) -> Int {
        if xp <= 0 { return 1 }
        var lo = 1
        var hi = maxLevel
        while lo < hi {
            let mid = (lo + hi + 1) / 2
            if totalXpRequired(forLevel: mid) <= xp {
                lo = mid
            } else {
                hi = mid - 1
            }
        }
        return lo
    }

    /// XP needed for next level and percent progress.
    static func progressToNextLevel(forTotalXp xp: Int) -> (level: Int, currentLevelXp: Int, nextLevelXp: Int, percent: Double) {
        let lvl = level(forTotalXp: xp)
        let currentReq = totalXpRequired(forLevel: lvl)
        let nextReq = totalXpRequired(forLevel: min(lvl + 1, maxLevel))
        if nextReq == currentReq { return (lvl, xp, nextReq, 1.0) }
        let pct = Double(max(0, xp - currentReq)) / Double(max(1, nextReq - currentReq))
        return (lvl, xp, nextReq, min(max(pct, 0.0), 1.0))
    }

    /// Compute base XP for a time-based session.
    static func baseXpForMinutes(_ minutes: Int, skill: SkillKind) -> Int {
        if skill == .sleep {
            return max(0, minutes) * sleepXpPerMinute
        }
        return max(0, minutes) * timeXpPerMinute
    }
}
