//
//  APIFootballEnvelope.swift
//  LiveScore
//

import Foundation

struct APIFootballEnvelope<T: Decodable>: Decodable {
    let response: [T]
}

