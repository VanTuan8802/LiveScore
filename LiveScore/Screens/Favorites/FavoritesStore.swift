//
//  FavoritesStore.swift
//  LiveScore
//

import Foundation
import Combine

struct FavoriteTeam: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let logo: String?
}

@MainActor
final class FavoritesStore: ObservableObject {
    @Published private(set) var teams: [FavoriteTeam] = []

    private let defaults: UserDefaults
    private let storageKey = "favorite_teams"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    func isFavorite(_ id: Int) -> Bool {
        teams.contains { $0.id == id }
    }

    /// Adds the team to favorites (at the top) or removes it if already saved.
    func toggle(_ team: FavoriteTeam) {
        if isFavorite(team.id) {
            remove(team.id)
        } else {
            teams.insert(team, at: 0)
            persist()
        }
    }

    func remove(_ id: Int) {
        teams.removeAll { $0.id == id }
        persist()
    }

    private func load() {
        guard let data = defaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([FavoriteTeam].self, from: data) else {
            return
        }
        teams = decoded
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(teams) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
