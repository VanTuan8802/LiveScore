//
//  LeagueSection.swift
//  LiveScore
//

import Foundation

struct LeagueSection: Identifiable {
    let id: Int
    let name: String
    let logo: String?
    let round: String?
    var matches: [AFFixtureResponse]

    var shortCode: String {
        let words = name.split(separator: " ")
        if words.count >= 2 {
            return words.prefix(2).map { String($0.prefix(1)).uppercased() }.joined()
        }
        return String(name.prefix(3)).uppercased()
    }
}

