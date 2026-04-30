//
//  LeagueService.swift
//  LiveScore
//

import Foundation

protocol LeagueServiceType {
    func getLeagues() async throws -> [AFLeagueResponse]
    func getLeagueDetail(leagueId: Int) async throws -> AFLeagueResponse?
    func getStandings(leagueId: Int, season: Int) async throws -> AFStandingsResponse?
    func getTeamsByLeague(leagueId: Int) async throws -> [AFLeagueTeamResponse]
}

final class LeagueService: LeagueServiceType {
    static let shared = LeagueService()

    private let apiService: APIServiceType
    private let calendar: Calendar

    init(apiService: APIServiceType = APIService.shared,
         calendar: Calendar = Calendar(identifier: .gregorian)) {
        self.apiService = apiService
        self.calendar = calendar
    }

    func getLeagues() async throws -> [AFLeagueResponse] {
        let envelope: APIFootballEnvelope<AFLeagueResponse> = try await apiService.request(.leagues)
        return envelope.response
    }

    func getLeagueDetail(leagueId: Int) async throws -> AFLeagueResponse? {
        let envelope: APIFootballEnvelope<AFLeagueResponse> = try await apiService
            .request(.leagueDetail(leagueId: leagueId))
        return envelope.response.first
    }

    func getStandings(leagueId: Int, season: Int) async throws -> AFStandingsResponse? {
        let envelope: APIFootballEnvelope<AFStandingsResponse> = try await apiService
            .request(.standings(leagueId: leagueId, season: season))
        return envelope.response.first
    }

    func getTeamsByLeague(leagueId: Int) async throws -> [AFLeagueTeamResponse] {
        let envelope: APIFootballEnvelope<AFLeagueTeamResponse> = try await apiService
            .request(.teamsByLeague(leagueId: leagueId, season: currentSeason))
        return envelope.response
    }

    private var currentSeason: Int {
        calendar.component(.year, from: Date())
    }
}

