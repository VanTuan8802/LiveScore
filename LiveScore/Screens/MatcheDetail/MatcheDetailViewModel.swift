//
//  MatcheDetailViewModel.swift
//  LiveScore
//
//  Created by VanTuan8802 on 30/4/26.
//

import Foundation
import Combine

@MainActor
final class MatcheDetailViewModel: ObservableObject {
    @Published var lineups: [AFFixtureLineup] = []
    @Published var highlights: [AFFixtureEvent] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    let match: AFFixtureResponse
    private let detailService: MatcheDetailServiceType

    init(match: AFFixtureResponse, detailService: MatcheDetailServiceType = MatcheDetailService.shared) {
        self.match = match
        self.detailService = detailService
    }

    func loadData() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            async let lineupsTask = detailService.getLineups(fixtureId: match.id)
            async let eventsTask = detailService.getEvents(fixtureId: match.id)
            let (fetchedLineups, fetchedEvents) = try await (lineupsTask, eventsTask)

            lineups = fetchedLineups
            highlights = fetchedEvents.sorted { ($0.time.elapsed ?? 0) < ($1.time.elapsed ?? 0) }
        } catch {
            lineups = []
            highlights = []
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
}

