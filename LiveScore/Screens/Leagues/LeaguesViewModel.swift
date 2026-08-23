//
//  LeaguesViewModel.swift
//  LiveScore
//

import Foundation
import Combine

@MainActor
final class LeaguesViewModel: ObservableObject {
    @Published var leagues: [AFLeagueResponse] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isLoadingMore: Bool = false

    private let leagueService: LeagueServiceType
    private let batchSize: Int
    private let staleInterval: TimeInterval
    private var allLeagues: [AFLeagueResponse] = []
    private var nextIndex: Int = 0
    private var lastLoadedAt: Date?

    init(
        leagueService: LeagueServiceType = LeagueService.shared,
        batchSize: Int = 20,
        staleInterval: TimeInterval = 300
    ) {
        self.leagueService = leagueService
        self.batchSize = batchSize
        self.staleInterval = staleInterval
    }

    func loadIfNeeded() async {
        guard shouldReload else { return }
        await loadLeagues(force: false)
    }

    func loadLeagues(force: Bool = true) async {
        if !force && !shouldReload { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let items = try await leagueService.getLeagues()
            allLeagues = prioritizeLeagues(items)
            leagues = []
            nextIndex = 0
            appendNextBatch()
            lastLoadedAt = Date()
        } catch {
            allLeagues = []
            leagues = []
            errorMessage = error.localizedDescription
        }
    }

    var hasMoreLeagues: Bool {
        nextIndex < allLeagues.count
    }

    func loadMoreIfNeeded(currentItem: AFLeagueResponse) {
        guard hasMoreLeagues else { return }
        guard let last = leagues.last, last.league.id == currentItem.league.id else { return }

        isLoadingMore = true
        appendNextBatch()
        isLoadingMore = false
    }

    private func appendNextBatch() {
        guard nextIndex < allLeagues.count else { return }
        let end = min(nextIndex + batchSize, allLeagues.count)
        leagues.append(contentsOf: allLeagues[nextIndex..<end])
        nextIndex = end
    }

    private var shouldReload: Bool {
        guard !allLeagues.isEmpty else { return true }
        guard let lastLoadedAt else { return true }
        return Date().timeIntervalSince(lastLoadedAt) > staleInterval
    }

    private func prioritizeLeagues(_ items: [AFLeagueResponse]) -> [AFLeagueResponse] {
        let priorityMap = Dictionary(uniqueKeysWithValues: AppConstants.preferredLeagueIDs.enumerated().map { ($1, $0) })
        return items.sorted { lhs, rhs in
            let lhsPriority = priorityMap[lhs.league.id] ?? Int.max
            let rhsPriority = priorityMap[rhs.league.id] ?? Int.max

            if lhsPriority != rhsPriority {
                return lhsPriority < rhsPriority
            }

            return lhs.league.name.localizedCaseInsensitiveCompare(rhs.league.name) == .orderedAscending
        }
    }
}

