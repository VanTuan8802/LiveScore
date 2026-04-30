//
//  MatcheDetailModels.swift
//  LiveScore
//
//  Created by VanTuan8802 on 30/4/26.
//

import Foundation

struct AFFixtureLineup: Decodable, Identifiable {
    let team: AFTeamSummary
    let formation: String?
    let startXI: [AFLineupPlayerWrapper]
    let substitutes: [AFLineupPlayerWrapper]

    var id: Int { team.id }
}

struct AFLineupPlayerWrapper: Decodable, Identifiable {
    let player: AFLineupPlayer
    var id: Int { player.id ?? UUID().hashValue }
}

struct AFLineupPlayer: Decodable {
    let id: Int?
    let name: String?
    let number: Int?
    let pos: String?
    let grid: String?
}

struct AFFixtureEvent: Decodable, Identifiable {
    let time: AFEventTime
    let team: AFTeamSummary?
    let player: AFEventActor?
    let assist: AFEventActor?
    let type: String?
    let detail: String?
    let comments: String?

    var id: String {
        "\(time.elapsed ?? 0)-\(type ?? "")-\(detail ?? "")-\(player?.name ?? "")-\(team?.id ?? 0)"
    }
}

struct AFEventTime: Decodable {
    let elapsed: Int?
    let extra: Int?
}

struct AFEventActor: Decodable {
    let id: Int?
    let name: String?
}

