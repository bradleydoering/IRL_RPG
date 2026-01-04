//
//  SkillDetailView.swift
//  IRL-RPG
//

import SwiftUI
import CoreData

struct SkillDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var skill: Skill

    @FetchRequest private var logs: FetchedResults<SessionLogEntity>

    private let timeService = TimeService()
    private let streakService = StreakService()

    @State private var logMode: LogMode = .timer
    @State private var manualMinutes: String = "30"
    @State private var manualDate: Date = Date()
    @State private var sessionDate: Date = Date()
    @State private var isTimerRunning = false
    @State private var timerStart: Date?
    @State private var elapsedSeconds: Int = 0
    @State private var timer: Timer?
    @State private var editLog: EditLogState?

    init(skill: Skill) {
        self.skill = skill
        let predicate = NSPredicate(format: "skillKindRaw == %@", skill.kindRaw ?? "")
        _logs = FetchRequest(
            entity: SessionLogEntity.entity(),
            sortDescriptors: [NSSortDescriptor(key: "createdAt", ascending: false)],
            predicate: predicate,
            animation: .default
        )
    }

    var body: some View {
        List {
            Section {
                HStack(spacing: 12) {
                    if let uiImage = UIImage(named: skill.assetName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 64, height: 64)
                    } else {
                        Image(systemName: skill.iconName)
                            .font(.system(size: 44))
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(skill.displayName)
                            .font(AppFont.custom(24, weight: .semibold))
                        Text("\(skill.levelValue) • \(skill.xpValue)")
                            .font(AppFont.custom(14))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }

                Text(skill.shortDescription)
                    .font(AppFont.custom(15))
                Text(skill.motivationalQuip)
                    .font(AppFont.custom(14))
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Tracking")
                        .font(AppFont.custom(16, weight: .semibold))
                    Text(skill.trackingDescription)
                        .font(AppFont.custom(14))
                        .foregroundColor(.secondary)
                }
            }

            if skill.isLoggable {
                Section("Log") {
                    if skill.skillKind?.isTimeBased == true {
                        timeBasedLogger
                    } else {
                        sessionLogger
                    }
                }
            } else {
                Section {
                    Text("This skill is auto-tracked and can’t be logged manually.")
                        .font(AppFont.custom(14))
                        .foregroundColor(.secondary)
                }
            }

            Section("Activity Log") {
                if logs.isEmpty {
                    Text("No sessions yet.")
                        .font(AppFont.custom(14))
                        .foregroundColor(.secondary)
                } else {
                    ForEach(logs) { log in
                        activityRow(for: log)
                            .swipeActions {
                                Button(role: .destructive) {
                                    delete(log)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                                Button {
                                    editLog = EditLogState(log: log, isTimeBased: skill.skillKind?.isTimeBased == true)
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                    }
                    .onDelete(perform: deleteLogs)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(skill.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            stopTimer()
        }
        .sheet(item: $editLog) { edit in
            EditLogSheet(
                state: edit,
                onSave: { updatedDate, updatedMinutes in
                    applyEdit(edit, date: updatedDate, minutes: updatedMinutes)
                }
            )
        }
    }

    private var timeBasedLogger: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Log Mode", selection: $logMode) {
                Text("Timer").tag(LogMode.timer)
                Text("Manual").tag(LogMode.manual)
            }
            .pickerStyle(.segmented)

            if logMode == .timer {
                HStack(spacing: 12) {
                    Text(formatElapsed(elapsedSeconds))
                        .font(.system(size: 20, weight: .semibold, design: .monospaced))
                    Spacer()
                    Button(isTimerRunning ? "Stop" : "Start") {
                        isTimerRunning ? stopAndLogTimer() : startTimer()
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    DatePicker("Completed at", selection: $manualDate)
                        .datePickerStyle(.compact)
                    TextField("Minutes", text: $manualMinutes)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)

                    Button("Log activity") {
                        logTimeBased(minutes: manualMinutesValue, at: manualDate)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(manualMinutesValue <= 0)
                }
            }
        }
    }

    private var sessionLogger: some View {
        VStack(alignment: .leading, spacing: 8) {
            DatePicker("Completed at", selection: $sessionDate)
                .datePickerStyle(.compact)
            Button("Log session") {
                logSession(at: sessionDate)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var manualMinutesValue: Int {
        max(0, Int(manualMinutes) ?? 0)
    }

    private func startTimer() {
        isTimerRunning = true
        timerStart = Date()
        elapsedSeconds = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            guard let start = timerStart else { return }
            elapsedSeconds = max(0, Int(Date().timeIntervalSince(start)))
        }
    }

    private func stopTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
    }

    private func stopAndLogTimer() {
        guard let start = timerStart else { return }
        let totalSeconds = max(0, Int(Date().timeIntervalSince(start)))
        stopTimer()
        let minutes = max(1, Int((Double(totalSeconds) / 60.0).rounded()))
        logTimeBased(minutes: minutes, at: Date())
    }

    private func formatElapsed(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    private func logTimeBased(minutes: Int, at date: Date) {
        logEvent(at: date, minutes: minutes, sessions: 1)
    }

    private func logSession(at date: Date) {
        logEvent(at: date, minutes: 0, sessions: 1)
    }

    private func logEvent(at date: Date, minutes: Int, sessions: Int) {
        guard let kind = skill.skillKind else { return }
        let trainedDay = timeService.localDay(for: date)
        let lastTrainedDay = skill.lastTrainedAt.map { timeService.localDay(for: $0) }

        let update = streakService.updateStreak(
            lastTrainedDay: lastTrainedDay,
            currentStreakDays: Int(skill.currentStreakDays),
            longestStreakDays: Int(skill.longestStreakDays),
            trainedDay: trainedDay
        )

        let baseXp = XPService.baseXp(skill: kind, minutes: minutes, sessions: sessions)
        let breakdown = XPService.breakdown(baseXp: baseXp,
                                            streakDays: update.currentStreakDays,
                                            bonusXp: 0)

        withAnimation {
            skill.xpTotal += Int64(breakdown.totalXp)
            skill.currentStreakDays = Int16(update.currentStreakDays)
            skill.longestStreakDays = Int16(update.longestStreakDays)
            skill.lastTrainedAt = timeService.startOfDay(for: trainedDay)
            skill.updatedAt = date

            let log = SessionLogEntity(context: viewContext)
            log.id = UUID()
            log.skillKindRaw = kind.rawValue
            log.startAt = date
            log.endAt = minutes > 0 ? date.addingTimeInterval(TimeInterval(minutes * 60)) : nil
            log.durationSeconds = Int64(max(0, minutes * 60))
            log.baseXp = Int64(baseXp)
            log.streakMultiplier = breakdown.streakMultiplier
            log.bonusXp = 0
            log.totalXp = Int64(breakdown.totalXp)
            log.trainedDespiteResistance = false
            log.sourceRaw = SessionSource.manual.rawValue
            log.createdAt = Date()

            let event = XpEventEntity(context: viewContext)
            event.id = UUID()
            event.at = Date()
            event.skillKindRaw = kind.rawValue
            event.typeRaw = XpEventType.base.rawValue
            event.amount = Int64(breakdown.totalXp)
            event.note = update.isSameDay ? "Same-day session" : nil

            if kind.category == .hobby, let creativity = fetchSkill(kind: .creativity) {
                let creativityBonus = Int((Double(baseXp) * GameRules.creativityHobbyXpMultiplier).rounded())
                if creativityBonus > 0 {
                    creativity.xpTotal += Int64(creativityBonus)
                    creativity.updatedAt = date

                    let creativityEvent = XpEventEntity(context: viewContext)
                    creativityEvent.id = UUID()
                    creativityEvent.at = Date()
                    creativityEvent.skillKindRaw = SkillKind.creativity.rawValue
                    creativityEvent.typeRaw = XpEventType.creativity.rawValue
                    creativityEvent.amount = Int64(creativityBonus)
                    creativityEvent.note = "Hobby activity bonus"
                }
            }

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func activityRow(for log: SessionLogEntity) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(formatDate(log.startAt ?? log.createdAt ?? Date()))
                    .font(AppFont.custom(14))
                Text(durationText(for: log))
                    .font(AppFont.custom(12))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("\(log.totalXp)")
                .font(AppFont.custom(14, weight: .semibold))
        }
    }

    private func durationText(for log: SessionLogEntity) -> String {
        let seconds = Int(log.durationSeconds)
        if seconds <= 0 {
            return "Session"
        }
        let mins = max(1, Int((Double(seconds) / 60.0).rounded()))
        return "\(mins) min"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func delete(_ log: SessionLogEntity) {
        let delta = -Int(log.totalXp)
        skill.xpTotal += Int64(delta)

        if skill.skillKind?.category == .hobby, let creativity = fetchSkill(kind: .creativity) {
            let creativityDelta = -Int((Double(log.baseXp) * GameRules.creativityHobbyXpMultiplier).rounded())
            creativity.xpTotal += Int64(creativityDelta)
            creativity.updatedAt = Date()
        }

        viewContext.delete(log)
        saveContext()
    }

    private func deleteLogs(at offsets: IndexSet) {
        for index in offsets {
            delete(logs[index])
        }
    }

    private func applyEdit(_ edit: EditLogState, date: Date, minutes: Int) {
        guard let kind = skill.skillKind else { return }
        let oldTotal = Int(edit.log.totalXp)
        let oldBase = Int(edit.log.baseXp)

        let newBase = XPService.baseXp(skill: kind, minutes: minutes, sessions: 1)
        let newTotal = Int((Double(newBase) * edit.log.streakMultiplier).rounded())
        let delta = newTotal - oldTotal

        edit.log.startAt = date
        edit.log.endAt = minutes > 0 ? date.addingTimeInterval(TimeInterval(minutes * 60)) : nil
        edit.log.durationSeconds = Int64(max(0, minutes * 60))
        edit.log.baseXp = Int64(newBase)
        edit.log.totalXp = Int64(newTotal)
        edit.log.createdAt = Date()

        skill.xpTotal += Int64(delta)
        skill.updatedAt = Date()

        if kind.category == .hobby, let creativity = fetchSkill(kind: .creativity) {
            let oldBonus = Int((Double(oldBase) * GameRules.creativityHobbyXpMultiplier).rounded())
            let newBonus = Int((Double(newBase) * GameRules.creativityHobbyXpMultiplier).rounded())
            creativity.xpTotal += Int64(newBonus - oldBonus)
            creativity.updatedAt = Date()
        }

        saveContext()
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    private func fetchSkill(kind: SkillKind) -> Skill? {
        let request = NSFetchRequest<Skill>(entityName: "Skill")
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "kindRaw == %@", kind.rawValue)
        return try? viewContext.fetch(request).first
    }
}

private enum LogMode {
    case timer
    case manual
}
