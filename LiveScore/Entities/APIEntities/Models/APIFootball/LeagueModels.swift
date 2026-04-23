//
//  LeagueModels.swift
//  LiveScore
//

import Foundation

struct AFLeagueResponse: Decodable {
    let league: AFLeague
    let country: AFCountry?
    let seasons: [AFSeason]?
}

struct AFLeague: Decodable {
    let id: Int
    let name: String
    let type: String?
    let logo: String?
}

struct AFCountry: Decodable {
    let name: String?
    let code: String?
    let flag: String?
}

struct AFSeason: Decodable {
    let year: Int
    let current: Bool?
}

struct AFStandingsResponse: Decodable {
    let league: AFStandingsLeague
}

struct AFStandingsLeague: Decodable {
    let id: Int
    let name: String
    let season: Int
    let standings: [[AFStandingRow]]
}

struct AFStandingRow: Decodable, Identifiable {
    let rank: Int
    let team: AFTeamSummary
    let points: Int
    let goalsDiff: Int
    let `group`: String?

    var id: Int { team.id }
}

struct AFLeagueTeamResponse: Decodable {
    let team: AFTeamSummary
}

