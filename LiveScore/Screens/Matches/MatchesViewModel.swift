//
//  MatchesViewModel.swift
//  LiveScore
//
//  Created by VanTuan8802 on 25/4/26.
//

import Foundation
import Combine

@MainActor
final class MatchesViewModel: ObservableObject {
    private static let topLeagues: [Int] = [39, 2, 140, 135, 78, 61]
    private static let topLeaguePriority: [Int: Int] = {
        Dictionary(uniqueKeysWithValues: topLeagues.enumerated().map { ($1, $0) })
    }()

    @Published var matches: [AFFixtureResponse] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let matchesService: MatchesServiceType

    @MainActor
    init(matchesService: MatchesServiceType = MatchesService.shared) {
        self.matchesService = matchesService
    }

    func loadMatches() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            _ = await RemoteConfigManager.shared.fetchAndActivate()

            let today = Self.dateFormatter.string(from: Date())
        

            let response = try await matchesService.getMatchesByDate(date: today)
        

            for match in response {
                let home = match.teams.home.name
                let away = match.teams.away.name
                let homeScore = match.goals.home.map(String.init) ?? "-"
                let awayScore = match.goals.away.map(String.init) ?? "-"
                
            }

            matches = prioritizeLeagues(in: response)
        } catch {
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

    private func prioritizeLeagues(in fixtures: [AFFixtureResponse]) -> [AFFixtureResponse] {
        fixtures.sorted { lhs, rhs in
            let lhsPriority = Self.topLeaguePriority[lhs.league.id] ?? Int.max
            let rhsPriority = Self.topLeaguePriority[rhs.league.id] ?? Int.max

            if lhsPriority != rhsPriority {
                return lhsPriority < rhsPriority
            }

            if lhs.fixture.date != rhs.fixture.date {
                return lhs.fixture.date < rhs.fixture.date
            }

            return lhs.league.id < rhs.league.id
        }
    }
}

