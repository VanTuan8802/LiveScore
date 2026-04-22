//
//  Match.swift
//  LiveScore
//
//  Created by VanTuan8802 on 22/4/26.
//

import Foundation

struct Match: Decodable, Identifiable {
    let id: Int
    let utcDate: Date
    let status: String
    let minute: Int?
    let competition: CompetitionBrief?
    let homeTeam: TeamBrief
    let awayTeam: TeamBrief
    let score: MatchScore
}
