//
//  AddFavoriteTeamViewModel.swift
//  LiveScore
//

import Foundation
import Combine

@MainActor
final class AddFavoriteTeamViewModel: ObservableObject {
    @Published var leagues: [AFLeagueResponse] = []
    @Published var teams: [AFTeamSummary] = []
    @Published var selectedLeagueId: Int?
    @Published var isLoadingLeagues: Bool = false
    @Published var isLoadingTeams: Bool = false
    @Published var errorMessage: String?
    @Published var searchText: String = ""

    private let leagueService: LeagueServiceType

    init(leagueService: LeagueServiceType = LeagueService.shared) {
        self.leagueService = leagueService
    }

    var filteredTeams: [AFTeamSummary] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return teams }
        return teams.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    func loadLeaguesIfNeeded() async {
        guard leagues.isEmpty else { return }
        isLoadingLeagues = true
        do {
            let items = try await leagueService.getLeagues()
            leagues = preferredLeagues(items)
            isLoadingLeagues = false
            if let first = leagues.first?.league.id {
                await selectLeague(first)
            }
        } catch {
            isLoadingLeagues = false
            errorMessage = error.localizedDescription
        }
    }

    func selectLeague(_ id: Int) async {
        guard selectedLeagueId != id || teams.isEmpty else { return }
        selectedLeagueId = id
        await loadTeams(leagueId: id)
    }

    private func loadTeams(leagueId: Int) async {
        isLoadingTeams = true
        teams = []
        defer { isLoadingTeams = false }
        do {
            let response = try await leagueService.getTeamsByLeague(leagueId: leagueId)
            teams = response
                .map(\.team)
                .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func preferredLeagues(_ items: [AFLeagueResponse]) -> [AFLeagueResponse] {
        let priorityMap = Dictionary(uniqueKeysWithValues: AppConstants.preferredLeagueIDs.enumerated().map { ($1, $0) })
        return items
            .filter { priorityMap[$0.league.id] != nil }
            .sorted { (priorityMap[$0.league.id] ?? Int.max) < (priorityMap[$1.league.id] ?? Int.max) }
    }
}
