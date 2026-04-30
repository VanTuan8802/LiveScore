//
//  APIService.swift
//  LiveScore
//
//  Created by VanTuan8802 on 22/4/26.
//


import Foundation
import Alamofire

// MARK: - Protocol

protocol APIServiceType {
    func request<T: Decodable>(_ route: APIRouter) async throws -> T
    func requestVoid(_ route: APIRouter) async throws
}

// MARK: - Implementation

final class APIService: APIServiceType {
    static let shared = APIService()

    private let session: Session
    private let decoder: JSONDecoder
    private let emptyResponseCodes: Set<Int> = [204, 205]

    init(
        session: Session = APIService.makeDefaultSession(),
        decoder: JSONDecoder = APIService.makeDefaultDecoder()
    ) {
        self.session = session
        self.decoder = decoder
    }

    // MARK: - Public

    func request<T: Decodable>(_ route: APIRouter) async throws -> T {
        let response = await session.request(route)
            .validate(statusCode: 200..<300)
            .serializingData(emptyResponseCodes: emptyResponseCodes)
            .response

        log(response: response)

        switch response.result {
        case .success(let data):
            guard !data.isEmpty else {
                throw APIError.emptyResponse
            }
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decoding(error)
            }

        case .failure(let afError):
            throw mapError(afError, data: response.data, httpResponse: response.response)
        }
    }

    func requestVoid(_ route: APIRouter) async throws {
        let response = await session.request(route)
            .validate(statusCode: 200..<300)
            .serializingData(emptyResponseCodes: emptyResponseCodes)
            .response

        log(response: response)

        if case .failure(let afError) = response.result {
            throw mapError(afError, data: response.data, httpResponse: response.response)
        }
    }

    // MARK: - Error Mapping

    private func mapError(_ error: AFError,
                          data: Data?,
                          httpResponse: HTTPURLResponse?) -> APIError {
        if error.isExplicitlyCancelledError {
            return .cancelled
        }

        if let status = httpResponse?.statusCode {
            let retryAfter = httpResponse?.value(forHTTPHeaderField: "Retry-After").flatMap(TimeInterval.init)
            return APIError.from(statusCode: status, data: data, retryAfter: retryAfter)
        }

        if let urlError = error.underlyingError as? URLError {
            switch urlError.code {
            case .cancelled:
                return .cancelled
            case .timedOut:
                return .timeout
            case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
                return .noInternet
            default:
                break
            }
        }

        if case .responseSerializationFailed(let reason) = error,
           case .decodingFailed(let underlying) = reason {
            return .decoding(underlying)
        }

        return .network(error)
    }

    // MARK: - Logging

    private func log(response: AFDataResponse<Data>) {
        #if DEBUG
        let method = response.request?.httpMethod ?? "?"
        let url = response.request?.url?.absoluteString ?? "-"
        let status = response.response?.statusCode ?? -1
        print("[API] \(method) \(status) \(url)")

        if let data = response.data, !data.isEmpty,
           let pretty = prettyPrinted(data: data) {
            print("[API] body:\n\(pretty)")
        }
        #endif
    }

    private func prettyPrinted(data: Data) -> String? {
        if let object = try? JSONSerialization.jsonObject(with: data),
           let formatted = try? JSONSerialization.data(withJSONObject: object,
                                                       options: [.prettyPrinted, .sortedKeys]) {
            return String(data: formatted, encoding: .utf8)
        }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Factories

    private static func makeDefaultSession() -> Session {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        configuration.waitsForConnectivity = true
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return Session(configuration: configuration)
    }

    private static func makeDefaultDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .useDefaultKeys
        return decoder
    }
}
