//
//  LeagueDetailViewModel.swift
//  LiveScore
//

import Foundation
import Combine

@MainActor
final class LeagueDetailViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var isLoadingRound: Bool = false
    @Published var errorMessage: String?
    @Published var rounds: [String] = []
    @Published var selectedRoundIndex: Int = 0

    private let matchesService: MatchesServiceType
    private let leagueId: Int
    private var season: Int = 0
    private var fixturesByRound: [String: [AFFixtureResponse]] = [:]

    init(leagueId: Int, matchesService: MatchesServiceType = MatchesService.shared) {
        self.leagueId = leagueId
        self.matchesService = matchesService
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        fixturesByRound = [:]
        defer { isLoading = false }

        do {
            let (resolvedSeason, roundList) = try await matchesService.getLeagueRounds(leagueId: leagueId)
            season = resolvedSeason
            rounds = sortRounds(roundList)

            let currentRound = try await matchesService.getCurrentRound(leagueId: leagueId, season: season)
            var recentRound: String?
            if currentRound == nil || !rounds.contains(where: { $0 == currentRound }) {
                recentRound = try await matchesService.getRecentRound(leagueId: leagueId, season: season)
            }
            selectedRoundIndex = resolveInitialRoundIndex(
                rounds: rounds,
                currentRound: currentRound,
                recentRound: recentRound
            )

            await loadRound(at: selectedRoundIndex, showLoading: false)
        } catch {
            rounds = []
            selectedRoundIndex = 0
            fixturesByRound = [:]
            errorMessage = error.localizedDescription
        }
    }

    var selectedRoundTitle: String {
        guard rounds.indices.contains(selectedRoundIndex) else { return "-" }
        return rounds[selectedRoundIndex]
    }

    var selectedRoundFixtures: [AFFixtureResponse] {
        guard rounds.indices.contains(selectedRoundIndex) else { return [] }
        return fixturesByRound[rounds[selectedRoundIndex]] ?? []
    }

    var canGoPrevious: Bool { selectedRoundIndex > 0 }
    var canGoNext: Bool { selectedRoundIndex < rounds.count - 1 }

    func goPreviousRound() {
        guard canGoPrevious else { return }
        selectedRoundIndex -= 1
        Task { await loadRound(at: selectedRoundIndex) }
    }

    func goNextRound() {
        guard canGoNext else { return }
        selectedRoundIndex += 1
        Task { await loadRound(at: selectedRoundIndex) }
    }

    private func loadRound(at index: Int, showLoading: Bool = true) async {
        guard rounds.indices.contains(index) else { return }
        let round = rounds[index]
        guard fixturesByRound[round] == nil else { return }

        if showLoading {
            isLoadingRound = true
        }
        defer {
            if showLoading {
                isLoadingRound = false
            }
        }

        do {
            let data = try await matchesService.getMatchesByLeagueRound(
                leagueId: leagueId,
                season: season,
                round: round
            )
            fixturesByRound[round] = data.sorted { $0.fixture.date < $1.fixture.date }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func resolveInitialRoundIndex(
        rounds: [String],
        currentRound: String?,
        recentRound: String?
    ) -> Int {
        guard !rounds.isEmpty else { return 0 }

        if let currentRound,
           let index = rounds.firstIndex(of: currentRound) {
            return index
        }

        if let recentRound,
           let index = rounds.firstIndex(of: recentRound) {
            return index
        }

        return max(0, rounds.count - 1)
    }

    private func sortRounds(_ rounds: [String]) -> [String] {
        rounds.sorted { lhs, rhs in
            let lhsOrder = extractRoundOrder(from: lhs)
            let rhsOrder = extractRoundOrder(from: rhs)
            if lhsOrder != rhsOrder {
                return lhsOrder < rhsOrder
            }
            return lhs.localizedCaseInsensitiveCompare(rhs) == .orderedAscending
        }
    }

    private func extractRoundOrder(from text: String) -> Int {
        let digits = text.compactMap { $0.isNumber ? $0 : nil }
        guard !digits.isEmpty, let value = Int(String(digits)) else { return Int.max }
        return value
    }
}
