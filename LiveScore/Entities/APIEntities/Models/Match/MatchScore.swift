//
//  MatchScore.swift
//  LiveScore
//
//  Created by VanTuan8802 on 22/4/26.
//

import Foundation

struct MatchScore: Decodable {
    let winner: String?
    let duration: String?
    let fullTime: ScoreLine?
    let halfTime: ScoreLine?
}
