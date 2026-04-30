//
//  WeekSelector.swift
//  LiveScore
//

import SwiftUI

struct WeekSelector: View {
    @Binding var selectedDate: Date
    let onTapCalendar: () -> Void
    private let offsets = Array(-2...3)

    var body: some View {
        HStack(spacing: 10) {
            ForEach(offsets, id: \.self) { offset in
                let date = Calendar.current.date(byAdding: .day, value: offset, to: selectedDate) ?? selectedDate
                Button {
                    selectedDate = date
                } label: {
                    VStack(spacing: 4) {
                        Text(Self.weekdayFormatter.string(from: date))
                            .font(.regular12)
                            .foregroundColor(isSelected(date) ? .white : .secondary)
                        Text(Self.dayFormatter.string(from: date))
                            .font(.semibold14)
                            .foregroundColor(isSelected(date) ? .white : .primary)
                    }
                    .frame(width: 46, height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(isSelected(date) ? Color("primary") : Color.white)
                    )
                }
                .buttonStyle(.plain)
            }

            Button(action: onTapCalendar) {
                Image(systemName: "calendar")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(width: 46, height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white)
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private func isSelected(_ date: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }

    private static let weekdayFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "EEE"
        return df
    }()

    private static let dayFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd"
        return df
    }()
}

