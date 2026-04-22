//
//  MatchesResponse.swift
//  LiveScore
//
//  Created by VanTuan8802 on 22/4/26.
//

import Foundation

struct MatchesResponse: Decodable {
    let resultSet: ResultSet?
    let matches: [Match]
}
