//
//  CompetitionBrief.swift
//  LiveScore
//
//  Created by VanTuan8802 on 22/4/26.
//

import Foundation

struct CompetitionBrief: Decodable {
    let id: Int
    let name: String
    let code: String?
    let emblem: String?
}
