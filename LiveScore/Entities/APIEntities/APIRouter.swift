//
//  APIRouter.swift
//  LiveScore
//
//  Created by VanTuan8802 on 22/4/26.
//


import Foundation
import Alamofire

enum APIRouter: URLRequestConvertible {
    case areas
    case competitions
    case competition(id: Int)
    case competitionMatches(id: Int, filters: MatchFilters = .init())
    case competitionTeams(id: Int, season: Int? = nil)
    case competitionStandings(id: Int, season: Int? = nil)
    case competitionScorers(id: Int, season: Int? = nil, limit: Int? = nil)
    case matchesToday(filters: MatchFilters = .init())
    case match(id: Int)
    case team(id: Int)
    case teamMatches(id: Int, filters: MatchFilters = .init())
    case person(id: Int)
    case personMatches(id: Int, filters: MatchFilters = .init())

    var baseURL: URL {
        return URL(string: AppConstants.baseURL)!
    }

    var method: HTTPMethod { .get }

    var path: String {
        switch self {
        case .areas:
            return "/areas"
        case .competitions:
            return "/competitions"
        case .competition(let id):
            return "/competitions/\(id)"
        case .competitionMatches(let id, _):
            return "/competitions/\(id)/matches"
        case .competitionTeams(let id, _):
            return "/competitions/\(id)/teams"
        case .competitionStandings(let id, _):
            return "/competitions/\(id)/standings"
        case .competitionScorers(let id, _, _):
            return "/competitions/\(id)/scorers"
        case .matchesToday:
            return "/matches"
        case .match(let id):
            return "/matches/\(id)"
        case .team(let id):
            return "/teams/\(id)"
        case .teamMatches(let id, _):
            return "/teams/\(id)/matches"
        case .person(let id):
            return "/persons/\(id)"
        case .personMatches(let id, _):
            return "/persons/\(id)/matches"
        }
    }

    var parameters: Parameters? {
        switch self {
        case .competitionMatches(_, let filters),
             .teamMatches(_, let filters),
             .personMatches(_, let filters),
             .matchesToday(let filters):
            return filters.asParameters()

        case .competitionTeams(_, let season),
             .competitionStandings(_, let season):
            guard let season else { return nil }
            return ["season": season]

        case .competitionScorers(_, let season, let limit):
            var params: Parameters = [:]
            if let season { params["season"] = season }
            if let limit { params["limit"] = limit }
            return params.isEmpty ? nil : params

        default:
            return nil
        }
    }

    var headers: HTTPHeaders {
        var headers: HTTPHeaders = ["Accept": "application/json"]
        let token = AppConstants.footballDataToken
        if !token.isEmpty {
            headers.add(name: "X-Auth-Token", value: token)
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

struct MatchFilters {
    var dateFrom: String?
    var dateTo: String?
    var status: MatchStatus?
    var matchday: Int?
    var stage: String?
    var group: String?
    var season: Int?
    var competitions: [Int]?
    var limit: Int?

    func asParameters() -> Parameters? {
        var params: Parameters = [:]
        if let dateFrom { params["dateFrom"] = dateFrom }
        if let dateTo { params["dateTo"] = dateTo }
        if let status { params["status"] = status.rawValue }
        if let matchday { params["matchday"] = matchday }
        if let stage { params["stage"] = stage }
        if let group { params["group"] = group }
        if let season { params["season"] = season }
        if let competitions, !competitions.isEmpty {
            params["competitions"] = competitions.map(String.init).joined(separator: ",")
        }
        if let limit { params["limit"] = limit }
        return params.isEmpty ? nil : params
    }
}

enum MatchStatus: String {
    case scheduled = "SCHEDULED"
    case live = "LIVE"
    case inPlay = "IN_PLAY"
    case paused = "PAUSED"
    case finished = "FINISHED"
    case postponed = "POSTPONED"
    case suspended = "SUSPENDED"
    case cancelled = "CANCELLED"
}
