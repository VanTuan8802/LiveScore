//
//  MatcheDetailService.swift
//  LiveScore
//

import Foundation
import Alamofire

protocol MatcheDetailServiceType {
    func getLineups(fixtureId: Int) async throws -> [AFFixtureLineup]
    func getEvents(fixtureId: Int) async throws -> [AFFixtureEvent]
}

final class MatcheDetailService: MatcheDetailServiceType {
    static let shared = MatcheDetailService()

    private let session: Session
    private let decoder: JSONDecoder

    init(session: Session = .default) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    func getLineups(fixtureId: Int) async throws -> [AFFixtureLineup] {
        let response: APIFootballEnvelope<AFFixtureLineup> = try await request(
            path: "/fixtures/lineups",
            queryItems: [URLQueryItem(name: "fixture", value: String(fixtureId))]
        )
        return response.response
    }

    func getEvents(fixtureId: Int) async throws -> [AFFixtureEvent] {
        let response: APIFootballEnvelope<AFFixtureEvent> = try await request(
            path: "/fixtures/events",
            queryItems: [URLQueryItem(name: "fixture", value: String(fixtureId))]
        )
        return response.response
    }

    private func request<T: Decodable>(path: String, queryItems: [URLQueryItem]) async throws -> T {
        guard var components = URLComponents(string: AppConstants.baseURL + path) else {
            throw APIError.invalidURL
        }
        components.queryItems = queryItems
        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var headers: HTTPHeaders = ["Accept": "application/json"]
        let apiKey = AppConstants.apiFootballKey
        if !apiKey.isEmpty {
            headers.add(name: "x-apisports-key", value: apiKey)
            headers.add(name: "x-apisports-host", value: "v3.football.api-sports.io")
        }

        let response = await session.request(url, headers: headers)
            .validate(statusCode: 200..<300)
            .serializingData()
            .response

        switch response.result {
        case .success(let data):
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decoding(error)
            }
        case .failure(let afError):
            if let status = response.response?.statusCode {
                throw APIError.from(statusCode: status, data: response.data)
            }
            throw APIError.network(afError)
        }
    }
}

