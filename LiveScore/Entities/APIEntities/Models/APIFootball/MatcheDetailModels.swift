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

struct AFFixtureStatisticsResponse: Decodable, Identifiable {
    let team: AFTeamSummary
    let statistics: [AFMatchStatistic]

    var id: Int { team.id }
}

struct AFMatchStatistic: Decodable, Identifiable {
    let type: String?
    let value: AFStatisticValue?

    var id: String { type ?? UUID().uuidString }
}

enum AFStatisticValue: Decodable {
    case int(Int)
    case string(String)
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
            return
        }
        if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
            return
        }
        if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
            return
        }
        self = .null
    }

    var displayText: String {
        switch self {
        case .int(let value):
            return "\(value)"
        case .string(let value):
            return value
        case .null:
            return "-"
        }
    }

    var numericValue: Double? {
        switch self {
        case .int(let value):
            return Double(value)
        case .string(let value):
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.hasSuffix("%") {
                return Double(trimmed.dropLast())
            }
            return Double(trimmed)
        case .null:
            return nil
        }
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

