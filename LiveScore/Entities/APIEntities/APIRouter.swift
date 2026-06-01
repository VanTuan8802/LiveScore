//
//  APIRouter.swift
//  LiveScore
//
//  Created by VanTuan8802 on 22/4/26.
//


import Foundation
import Alamofire

enum APIRouter: URLRequestConvertible {
    // Matches
    case fixturesByDate(date: String)
    case liveFixtures
    case fixturesByLeague(leagueId: Int, season: Int, round: String? = nil, last: Int? = nil)
    case fixtureRounds(leagueId: Int, season: Int, current: Bool? = nil)
    case fixturesByTeam(teamId: Int, season: Int)

    // Leagues
    case leagues
    case leagueDetail(leagueId: Int)
    case standings(leagueId: Int, season: Int)
    case teamsByLeague(leagueId: Int, season: Int)

    // Teams
    case teamInfo(teamId: Int)
    case teamSquad(teamId: Int)
    case teamStatistics(teamId: Int, leagueId: Int, season: Int)
    case leaguesByTeam(teamId: Int)

    var baseURL: URL {
        return URL(string: AppConstants.baseURL)!
    }

    var method: HTTPMethod { .get }

    var path: String {
        switch self {
        case .fixturesByDate, .liveFixtures, .fixturesByLeague, .fixturesByTeam:
            return "/fixtures"
        case .fixtureRounds:
            return "/fixtures/rounds"
        case .leagues, .leagueDetail, .leaguesByTeam:
            return "/leagues"
        case .standings:
            return "/standings"
        case .teamsByLeague, .teamInfo:
            return "/teams"
        case .teamSquad:
            return "/players/squads"
        case .teamStatistics:
            return "/teams/statistics"
        }
    }

    var parameters: Parameters? {
        switch self {
        case .fixturesByDate(let date):
            return ["date": date]
        case .liveFixtures:
            return ["live": "all"]
        case .fixturesByLeague(let leagueId, let season, let round, let last):
            var params: Parameters = ["league": leagueId, "season": season]
            if let round { params["round"] = round }
            if let last { params["last"] = last }
            return params
        case .fixtureRounds(let leagueId, let season, let current):
            var params: Parameters = ["league": leagueId, "season": season]
            if current == true { params["current"] = "true" }
            return params
        case .fixturesByTeam(let teamId, let season):
            return ["team": teamId, "season": season]
        case .leagueDetail(let leagueId):
            return ["id": leagueId]
        case .standings(let leagueId, let season):
            return ["league": leagueId, "season": season]
        case .teamsByLeague(let leagueId, let season):
            return ["league": leagueId, "season": season]
        case .teamInfo(let teamId):
            return ["id": teamId]
        case .teamSquad(let teamId):
            return ["team": teamId]
        case .teamStatistics(let teamId, let leagueId, let season):
            return ["team": teamId, "league": leagueId, "season": season]
        case .leaguesByTeam(let teamId):
            return ["team": teamId]
        case .leagues:
            return nil
        }
    }

    var headers: HTTPHeaders {
        var headers: HTTPHeaders = ["Accept": "application/json"]
        let apiKey = AppConstants.apiFootballKey
        if !apiKey.isEmpty {
            headers.add(name: "x-apisports-key", value: apiKey)
            headers.add(name: "x-apisports-host", value: "v3.football.api-sports.io")
        }
        return headers
    }

    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.method = method
        request.headers = headers
        return try URLEncoding.queryString.encode(request, with: parameters)
    }
}
