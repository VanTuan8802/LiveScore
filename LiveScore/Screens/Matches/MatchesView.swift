//
//  MatchesView.swift
//  LiveScore
//
//  Created by VanTuan8802 on 19/4/26.
//

import SwiftUI

struct MatchesView: View {
    @State private var matches: [AFFixtureResponse] = []
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
            .navigationTitle(Text(String(localized: .matches)))
            .task { await loadMatches() }
            .refreshable { await loadMatches() }
        }
    }

    private func loadMatches() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            _ = await RemoteConfigManager.shared.fetchAndActivate()

            let today = Self.dateFormatter.string(from: Date())

            print("[MatchesView] Fetching matches for \(today)")
            let response = try await MatchesService.shared.getMatchesByDate(date: today)

            print("[MatchesView] Total matches: \(response.count)")
            for match in response {
                let home = match.teams.home.name
                let away = match.teams.away.name
                let homeScore = match.goals.home.map(String.init) ?? "-"
                let awayScore = match.goals.away.map(String.init) ?? "-"
                print("[MatchesView] #\(match.fixture.id) [\(match.fixture.status.short)] \(home) \(homeScore)-\(awayScore) \(away) @ \(match.fixture.date)")
            }

            matches = response
        } catch {
            print("[MatchesView] Error: \(error)")
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
    let match: AFFixtureResponse

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(match.league.name)
                    .font(.medium12)
                    .foregroundColor(.secondary)
                HStack {
                    Text(match.teams.home.name)
                        .font(.semibold14)
                    Spacer()
                    Text(scoreText)
                        .font(.semibold14)
                }
                HStack {
                    Text(match.teams.away.name)
                        .font(.regular14)
                    Spacer()
                    Text(Self.timeFormatter.string(from: match.fixture.date))
                        .font(.regular14)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 6)
    }

    private var scoreText: String {
        let home = match.goals.home
        let away = match.goals.away
        if let home, let away {
            return "\(home) - \(away)"
        }
        return match.fixture.status.short
    }

    private static let timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        return df
    }()
}

#Preview {
    MatchesView()
}
