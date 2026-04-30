//
//  TeamModels.swift
//  LiveScore
//

import Foundation

struct AFTeamInfoResponse: Decodable {
    let team: AFTeamInfo
}

struct AFTeamInfo: Decodable {
    let id: Int
    let name: String
    let code: String?
    let country: String?
    let founded: Int?
    let logo: String?
}

struct AFTeamSquadResponse: Decodable {
    let team: AFTeamInfo
    let players: [AFSquadPlayer]
}

struct AFSquadPlayer: Decodable, Identifiable {
    let id: Int
    let name: String
    let age: Int?
    let number: Int?
    let position: String?
    let photo: String?
}

struct AFTeamStatisticsResponse: Decodable {
    let league: AFLeagueSummary
    let team: AFTeamSummary
}

