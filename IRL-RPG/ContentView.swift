//
//  ContentView.swift
//  IRL-RPG
//
//  Created by Brad Doering on 1/3/26.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(key: "categoryRaw", ascending: true),
            NSSortDescriptor(key: "kindRaw", ascending: true)
        ],
        animation: .default)
    private var skills: FetchedResults<Skill>

    private let timeService = TimeService()
    private let streakService = StreakService()

    var body: some View {
        NavigationView {
            List {
                ForEach(SkillCategory.allCases, id: \.self) { category in
                    let categorySkills = skills.filter { $0.category == category }
                    if !categorySkills.isEmpty {
                        Section(category.displayName) {
                            ForEach(categorySkills) { skill in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(skill.displayName)
                                            .font(AppFont.custom(18, weight: .semibold))
                                        Text(skill.levelSubtitle)
                                            .font(AppFont.custom(13))
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Button("Log") {
                                        logQuickSession(for: skill)
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Skills")
            .toolbar {
                ToolbarItem {
                    Button("Seed Skills") {
                        PersistenceController.shared.seedSkillsIfNeeded(context: viewContext)
                    }
                }
            }
            .onAppear {
                PersistenceController.shared.seedSkillsIfNeeded(context: viewContext)
            }
        }
    }

    private func logQuickSession(for skill: Skill) {
        guard let kind = skill.skillKind else { return }
        let now = Date()
        let trainedDay = timeService.localDay(for: now)
        let lastTrainedDay = skill.lastTrainedAt.map { timeService.localDay(for: $0) }

        let update = streakService.updateStreak(
            lastTrainedDay: lastTrainedDay,
            currentStreakDays: Int(skill.currentStreakDays),
            longestStreakDays: Int(skill.longestStreakDays),
            trainedDay: trainedDay
        )

        let minutes = kind.isTimeBased ? 30 : 0
        let baseXp = XPService.baseXp(skill: kind, minutes: minutes, sessions: 1)
        let breakdown = XPService.breakdown(baseXp: baseXp,
                                            streakDays: update.currentStreakDays,
                                            bonusXp: 0)

        withAnimation {
            skill.xpTotal += Int64(breakdown.totalXp)
            skill.currentStreakDays = Int16(update.currentStreakDays)
            skill.longestStreakDays = Int16(update.longestStreakDays)
            skill.lastTrainedAt = timeService.startOfDay(for: trainedDay)
            skill.updatedAt = now

            let log = SessionLogEntity(context: viewContext)
            log.id = UUID()
            log.skillKindRaw = kind.rawValue
            log.durationSeconds = Int64(minutes * 60)
            log.baseXp = Int64(baseXp)
            log.streakMultiplier = breakdown.streakMultiplier
            log.bonusXp = 0
            log.totalXp = Int64(breakdown.totalXp)
            log.trainedDespiteResistance = false
            log.sourceRaw = SessionSource.manual.rawValue
            log.createdAt = now

            let event = XpEventEntity(context: viewContext)
            event.id = UUID()
            event.at = now
            event.skillKindRaw = kind.rawValue
            event.typeRaw = XpEventType.base.rawValue
            event.amount = Int64(breakdown.totalXp)
            event.note = update.isSameDay ? "Same-day session" : nil

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
