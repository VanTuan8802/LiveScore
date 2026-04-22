//
//  TodayView.swift
//  LiveScore
//
//  Created by VanTuan8802 on 19/4/26.
//

import SwiftUI

struct TodayView: View {
    @State private var matches: [Match] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage {
                    VStack(spacing: 12) {
                        Text("Error")
                            .font(.semibold20)
                        Text(errorMessage)
                            .font(.regular14)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 24)
                        Button("Retry") { Task { await loadMatches() } }
                            .font(.semibold14)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if matches.isEmpty {
                    Text("No matches today.")
                        .font(.regular16)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(matches) { match in
                        MatchRow(match: match)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(Text(String(localized: .today)))
            .task { await loadMatches() }
            .refreshable { await loadMatches() }
        }
    }

    private func loadMatches() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let today = Self.dateFormatter.string(from: Date())
            let filters = MatchFilters(dateFrom: today, dateTo: today)

            print("[TodayView] Fetching matches for \(today)")
            let response: MatchesResponse = try await APIService.shared
                .request(.matchesToday(filters: filters))

            print("[TodayView] Total matches: \(response.matches.count)")
            if let count = response.resultSet?.count {
                print("[TodayView] ResultSet count: \(count)")
            }
            for match in response.matches {
                let home = match.homeTeam.name ?? match.homeTeam.tla ?? "-"
                let away = match.awayTeam.name ?? match.awayTeam.tla ?? "-"
                let homeScore = match.score.fullTime?.home.map(String.init) ?? "-"
                let awayScore = match.score.fullTime?.away.map(String.init) ?? "-"
                print("[TodayView] #\(match.id) [\(match.status)] \(home) \(homeScore)-\(awayScore) \(away) @ \(match.utcDate)")
            }

            matches = response.matches
        } catch {
            print("[TodayView] Error: \(error)")
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(identifier: "UTC")
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
}

private struct MatchRow: View {
    let match: Match

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                if let competition = match.competition?.name {
                    Text(competition)
                        .font(.medium12)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text(match.homeTeam.name ?? match.homeTeam.tla ?? "-")
                        .font(.semibold14)
                    Spacer()
                    Text(scoreText)
                        .font(.semibold14)
                }
                HStack {
                    Text(match.awayTeam.name ?? match.awayTeam.tla ?? "-")
                        .font(.regular14)
                    Spacer()
                    Text(Self.timeFormatter.string(from: match.utcDate))
                        .font(.regular14)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 6)
    }

    private var scoreText: String {
        let home = match.score.fullTime?.home
        let away = match.score.fullTime?.away
        if let home, let away {
            return "\(home) - \(away)"
        }
        return match.status
    }

    private static let timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        return df
    }()
}

#Preview {
    TodayView()
}
