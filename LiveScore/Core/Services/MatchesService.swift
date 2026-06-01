//
//  MatchesService.swift
//  LiveScore
//

import Foundation

protocol MatchesServiceType {
    func getMatchesByDate(date: String) async throws -> [AFFixtureResponse]
    func getLiveMatches() async throws -> [AFFixtureResponse]
    func getMatchesByLeague(leagueId: Int) async throws -> [AFFixtureResponse]
    func getLeagueRounds(leagueId: Int) async throws -> (season: Int, rounds: [String])
    func getCurrentRound(leagueId: Int, season: Int) async throws -> String?
    func getRecentRound(leagueId: Int, season: Int) async throws -> String?
    func getMatchesByLeagueRound(leagueId: Int, season: Int, round: String) async throws -> [AFFixtureResponse]
    func getMatchesByTeam(teamId: Int) async throws -> [AFFixtureResponse]
}

final class MatchesService: MatchesServiceType {
    static let shared = MatchesService()

    private let apiService: APIServiceType
    private let calendar: Calendar

    init(apiService: APIServiceType = APIService.shared,
         calendar: Calendar = Calendar(identifier: .gregorian)) {
        self.apiService = apiService
        self.calendar = calendar
    }

    func getMatchesByDate(date: String) async throws -> [AFFixtureResponse] {
        let envelope: APIFootballEnvelope<AFFixtureResponse> = try await apiService
            .request(.fixturesByDate(date: date))
        return envelope.response
    }

    func getLiveMatches() async throws -> [AFFixtureResponse] {
        let envelope: APIFootballEnvelope<AFFixtureResponse> = try await apiService
            .request(.liveFixtures)
        return envelope.response
    }

    func getMatchesByLeague(leagueId: Int) async throws -> [AFFixtureResponse] {
        let current = try await fetchFixturesByLeague(leagueId: leagueId, season: currentSeason)
        guard current.isEmpty else { return current }
        return try await fetchFixturesByLeague(leagueId: leagueId, season: currentSeason - 1)
    }

    func getLeagueRounds(leagueId: Int) async throws -> (season: Int, rounds: [String]) {
        let current = currentSeason
        let currentRounds = try await fetchRounds(leagueId: leagueId, season: current)
        if !currentRounds.isEmpty {
            return (current, currentRounds)
        }

        let previous = current - 1
        let previousRounds = try await fetchRounds(leagueId: leagueId, season: previous)
        return (previous, previousRounds)
    }

    func getCurrentRound(leagueId: Int, season: Int) async throws -> String? {
        let envelope: APIFootballEnvelope<String> = try await apiService
            .request(.fixtureRounds(leagueId: leagueId, season: season, current: true))
        return envelope.response.first
    }

    func getRecentRound(leagueId: Int, season: Int) async throws -> String? {
        let envelope: APIFootballEnvelope<AFFixtureResponse> = try await apiService
            .request(.fixturesByLeague(leagueId: leagueId, season: season, last: 1))
        return envelope.response.first?.league.round
    }

    func getMatchesByLeagueRound(leagueId: Int, season: Int, round: String) async throws -> [AFFixtureResponse] {
        let envelope: APIFootballEnvelope<AFFixtureResponse> = try await apiService
            .request(.fixturesByLeague(leagueId: leagueId, season: season, round: round))
        return envelope.response
    }

    func getMatchesByTeam(teamId: Int) async throws -> [AFFixtureResponse] {
        let envelope: APIFootballEnvelope<AFFixtureResponse> = try await apiService
            .request(.fixturesByTeam(teamId: teamId, season: currentSeason))
        return envelope.response
    }

    private func fetchFixturesByLeague(leagueId: Int, season: Int) async throws -> [AFFixtureResponse] {
        let envelope: APIFootballEnvelope<AFFixtureResponse> = try await apiService
            .request(.fixturesByLeague(leagueId: leagueId, season: season))
        return envelope.response
    }

    private func fetchRounds(leagueId: Int, season: Int) async throws -> [String] {
        let envelope: APIFootballEnvelope<String> = try await apiService
            .request(.fixtureRounds(leagueId: leagueId, season: season))
        return envelope.response
    }

    private var currentSeason: Int {
        calendar.component(.year, from: Date())
    }
}
