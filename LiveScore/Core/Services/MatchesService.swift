//
//  MatchesService.swift
//  LiveScore
//

import Foundation

protocol MatchesServiceType {
    func getMatchesByDate(date: String) async throws -> [AFFixtureResponse]
    func getLiveMatches() async throws -> [AFFixtureResponse]
    func getMatchesByLeague(leagueId: Int) async throws -> [AFFixtureResponse]
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
        let envelope: APIFootballEnvelope<AFFixtureResponse> = try await apiService
            .request(.fixturesByLeague(leagueId: leagueId, season: currentSeason))
        return envelope.response
    }

    func getMatchesByTeam(teamId: Int) async throws -> [AFFixtureResponse] {
        let envelope: APIFootballEnvelope<AFFixtureResponse> = try await apiService
            .request(.fixturesByTeam(teamId: teamId, season: currentSeason))
        return envelope.response
    }

    private var currentSeason: Int {
        calendar.component(.year, from: Date())
    }
}

