//
//  TeamService.swift
//  LiveScore
//

import Foundation

protocol TeamServiceType {
    func getTeamInfo(teamId: Int) async throws -> AFTeamInfoResponse?
    func getTeamSquad(teamId: Int) async throws -> AFTeamSquadResponse?
    func getTeamStats(teamId: Int) async throws -> AFTeamStatisticsResponse?
}

final class TeamService: TeamServiceType {
    static let shared = TeamService()

    private let apiService: APIServiceType
    private let calendar: Calendar

    init(apiService: APIServiceType = APIService.shared,
         calendar: Calendar = Calendar(identifier: .gregorian)) {
        self.apiService = apiService
        self.calendar = calendar
    }

    func getTeamInfo(teamId: Int) async throws -> AFTeamInfoResponse? {
        let envelope: APIFootballEnvelope<AFTeamInfoResponse> = try await apiService
            .request(.teamInfo(teamId: teamId))
        return envelope.response.first
    }

    func getTeamSquad(teamId: Int) async throws -> AFTeamSquadResponse? {
        let envelope: APIFootballEnvelope<AFTeamSquadResponse> = try await apiService
            .request(.teamSquad(teamId: teamId))
        return envelope.response.first
    }

    func getTeamStats(teamId: Int) async throws -> AFTeamStatisticsResponse? {
        let leagueId = try await resolveLeagueId(for: teamId)
        let envelope: APIFootballEnvelope<AFTeamStatisticsResponse> = try await apiService
            .request(.teamStatistics(teamId: teamId, leagueId: leagueId, season: currentSeason))
        return envelope.response.first
    }

    private func resolveLeagueId(for teamId: Int) async throws -> Int {
        let envelope: APIFootballEnvelope<AFLeagueResponse> = try await apiService
            .request(.leaguesByTeam(teamId: teamId))
        if let currentLeague = envelope.response.first(where: { league in
            league.seasons?.contains(where: { $0.year == currentSeason && ($0.current ?? false) }) == true
        }) {
            return currentLeague.league.id
        }
        guard let firstLeague = envelope.response.first else {
            throw APIError.emptyResponse
        }
        return firstLeague.league.id
    }

    private var currentSeason: Int {
        calendar.component(.year, from: Date())
    }
}

