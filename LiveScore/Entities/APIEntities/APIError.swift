//
//  APIError.swift
//  LiveScore
//
//  Created by VanTuan8802 on 22/4/26.
//


import Foundation
import Alamofire

enum APIError: Error, LocalizedError {
    // Client-side
    case invalidURL
    case cancelled
    case timeout
    case noInternet

    // HTTP
    case badRequest(message: String?)
    case unauthorized(message: String?)
    case forbidden(message: String?)
    case notFound(message: String?)
    case tooManyRequests(retryAfter: TimeInterval?, message: String?)
    case statusCode(Int, Data?)

    // Payload
    case emptyResponse
    case decoding(Error)

    // Catch-all
    case network(AFError)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL invalid."
        case .cancelled:
            return "Request was cancelled."
        case .timeout:
            return "The request timed out."
        case .noInternet:
            return "No internet connection."
        case .badRequest(let message):
            return message ?? "Bad request."
        case .unauthorized(let message):
            return message ?? "Missing or invalid X-Auth-Token."
        case .forbidden(let message):
            return message ?? "Restricted resource. Upgrade your plan or sign in."
        case .notFound(let message):
            return message ?? "Resource not found."
        case .tooManyRequests(_, let message):
            return message ?? "You exceeded your API request quota."
        case .statusCode(let code, _):
            return "Error HTTP status code: \(code)"
        case .emptyResponse:
            return "Server returned an empty response."
        case .decoding(let err):
            return "Decode JSON error: \(err.localizedDescription)"
        case .network(let err):
            return "Network error: \(err.localizedDescription)"
        case .unknown(let err):
            return "Unknown error: \(err.localizedDescription)"
        }
    }

    static func from(statusCode: Int, data: Data?, retryAfter: TimeInterval? = nil) -> APIError {
        let message = FootballDataErrorMessage.parse(from: data)
        switch statusCode {
        case 400: return .badRequest(message: message)
        case 401: return .unauthorized(message: message)
        case 403: return .forbidden(message: message)
        case 404: return .notFound(message: message)
        case 429: return .tooManyRequests(retryAfter: retryAfter, message: message)
        default:  return .statusCode(statusCode, data)
        }
    }
}

private struct FootballDataErrorMessage: Decodable {
    let message: String?
    let error: String?

    static func parse(from data: Data?) -> String? {
        guard let data, !data.isEmpty else { return nil }
        let decoded = try? JSONDecoder().decode(FootballDataErrorMessage.self, from: data)
        return decoded?.message ?? decoded?.error
    }
}
