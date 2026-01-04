//
//  EditLogSheet.swift
//  IRL-RPG
//

import SwiftUI

struct EditLogSheet: View {
    @Environment(\.dismiss) private var dismiss
    let state: EditLogState
    let onSave: (Date, Int) -> Void

    @State private var date: Date
    @State private var minutesText: String

    init(state: EditLogState, onSave: @escaping (Date, Int) -> Void) {
        self.state = state
        self.onSave = onSave
        _date = State(initialValue: state.date)
        _minutesText = State(initialValue: "\(state.minutes)")
    }

    var body: some View {
        NavigationView {
            Form {
                DatePicker("Completed at", selection: $date)
                    .datePickerStyle(.compact)

                if state.isTimeBased {
                    TextField("Minutes", text: $minutesText)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Edit Log")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(date, max(0, Int(minutesText) ?? state.minutes))
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct EditLogState: Identifiable {
    let id = UUID()
    let log: SessionLogEntity
    let isTimeBased: Bool
    let date: Date
    let minutes: Int

    init(log: SessionLogEntity, isTimeBased: Bool) {
        self.log = log
        self.isTimeBased = isTimeBased
        self.date = log.startAt ?? log.createdAt ?? Date()
        self.minutes = max(0, Int(log.durationSeconds / 60))
    }
}
