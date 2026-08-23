//
//  StatsTab.swift
//  LiveScore
//

import SwiftUI

struct StatsTab: View {
    let isLoading: Bool
    let errorMessage: String?
    let statistics: [AFFixtureStatisticsResponse]
    let homeTeamId: Int
    let awayTeamId: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isLoading {
                ProgressView(String(localized: .loadingStats))
            } else if let errorMessage {
                Text(errorMessage)
                    .font(.regular14)
                    .foregroundColor(.secondary)
            } else if statRows.isEmpty {
                Text(String(localized: .noStatsAvailable))
                    .font(.regular14)
                    .foregroundColor(.secondary)
            } else {
                ForEach(statRows) { row in
                    statRowView(row)
                }
            }
        }
    }

    private var statRows: [StatComparisonRow] {
        guard
            let homeStats = statistics.first(where: { $0.team.id == homeTeamId }),
            let awayStats = statistics.first(where: { $0.team.id == awayTeamId })
        else {
            return []
        }

        let homeMap = Dictionary(uniqueKeysWithValues: homeStats.statistics.compactMap { stat -> (String, AFMatchStatistic)? in
            guard let type = stat.type else { return nil }
            return (type, stat)
        })
        let awayMap = Dictionary(uniqueKeysWithValues: awayStats.statistics.compactMap { stat -> (String, AFMatchStatistic)? in
            guard let type = stat.type else { return nil }
            return (type, stat)
        })

        let types = homeStats.statistics.compactMap(\.type) + awayStats.statistics.compactMap(\.type)
        let uniqueTypes = Array(Set(types)).sorted()

        return uniqueTypes.compactMap { type in
            guard let home = homeMap[type], let away = awayMap[type] else { return nil }
            return StatComparisonRow(
                id: type,
                title: type,
                homeValue: home.value?.displayText ?? "-",
                awayValue: away.value?.displayText ?? "-",
                homeNumeric: home.value?.numericValue,
                awayNumeric: away.value?.numericValue
            )
        }
    }

    private func statRowView(_ row: StatComparisonRow) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(row.homeValue)
                    .font(.semibold14)
                    .frame(width: 44, alignment: .trailing)

                Text(row.title)
                    .font(.regular14)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                Text(row.awayValue)
                    .font(.semibold14)
                    .frame(width: 44, alignment: .leading)
            }

            if let homeNumeric = row.homeNumeric, let awayNumeric = row.awayNumeric {
                GeometryReader { proxy in
                    HStack(spacing: 4) {
                        bar(value: homeNumeric, total: max(homeNumeric + awayNumeric, 1), width: proxy.size.width / 2 - 2, alignment: .trailing)
                        bar(value: awayNumeric, total: max(homeNumeric + awayNumeric, 1), width: proxy.size.width / 2 - 2, alignment: .leading)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
    }

    private func bar(value: Double, total: Double, width: CGFloat, alignment: HorizontalAlignment) -> some View {
        ZStack(alignment: alignment == .trailing ? .trailing : .leading) {
            Capsule()
                .fill(Color(.systemGray5))
            Capsule()
                .fill(Color("primary"))
                .frame(width: max(4, width * CGFloat(value / total)))
        }
        .frame(width: width, height: 8)
    }
}

private struct StatComparisonRow: Identifiable {
    let id: String
    let title: String
    let homeValue: String
    let awayValue: String
    let homeNumeric: Double?
    let awayNumeric: Double?
}

#Preview {
    StatsTab(
        isLoading: false,
        errorMessage: nil,
        statistics: [],
        homeTeamId: 1,
        awayTeamId: 2
    )
}
