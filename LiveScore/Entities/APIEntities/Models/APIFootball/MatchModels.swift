//
//  MatchModels.swift
//  LiveScore
//

import Foundation

struct AFFixtureResponse: Decodable, Identifiable {
    let fixture: AFFixture
    let league: AFLeagueSummary
    let teams: AFFixtureTeams
    let goals: AFGoals

    var id: Int { fixture.id }
}

struct AFFixture: Decodable {
    let id: Int
    let date: Date
    let status: AFFixtureStatus
}

struct AFFixtureStatus: Decodable {
    let short: String
    let elapsed: Int?
}

struct AFLeagueSummary: Decodable {
    let id: Int
    let name: String
    let country: String?
    let logo: String?
    let season: Int?
    let round: String?
}

struct AFFixtureTeams: Decodable {
    let home: AFTeamSummary
    let away: AFTeamSummary
}

struct AFTeamSummary: Decodable {
    let id: Int
    let name: String
    let logo: String?
    let winner: Bool?
}

struct AFGoals: Decodable {
    let home: Int?
    let away: Int?
}

