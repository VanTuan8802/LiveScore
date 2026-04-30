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

    func loadMatches(for date: Date = Date()) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            _ = await RemoteConfigManager.shared.fetchAndActivate()

            let response = try await fetchMatchesAroundSelectedDate(date)
            let filtered = filterMatchesByDeviceDate(response, selectedDate: date)
            matches = prioritizeLeagues(in: filtered)
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = .autoupdatingCurrent
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()

    private func fetchMatchesAroundSelectedDate(_ date: Date) async throws -> [AFFixtureResponse] {
        let calendar = Calendar.autoupdatingCurrent
        let dates = [-1, 0, 1].compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: date)
        }

        var mergedByID: [Int: AFFixtureResponse] = [:]
        for day in dates {
            let dayString = Self.dateFormatter.string(from: day)
            let fixtures = try await matchesService.getMatchesByDate(date: dayString)
            for fixture in fixtures {
                mergedByID[fixture.id] = fixture
            }
        }
        return Array(mergedByID.values)
    }

    private func filterMatchesByDeviceDate(_ fixtures: [AFFixtureResponse], selectedDate: Date) -> [AFFixtureResponse] {
        let calendar = Calendar.autoupdatingCurrent
        return fixtures.filter { fixture in
            calendar.isDate(fixture.fixture.date, inSameDayAs: selectedDate)
        }
    }

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

