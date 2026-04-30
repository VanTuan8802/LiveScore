//
//  MatcheDetailView.swift
//  LiveScore
//
//  Created by VanTuan8802 on 30/4/26.
//

import SwiftUI
import UIKit

struct MatcheDetailView: View {
    enum DetailTab: String, CaseIterable, Identifiable {
        case lineup = "Lineup"
        case highlight = "Highlight"

        var id: String { rawValue }
    }

    @StateObject private var viewModel: MatcheDetailViewModel
    @State private var selectedTab: DetailTab = .lineup
    @State private var expandedLineupIDs: Set<Int> = []

    init(match: AFFixtureResponse) {
        _viewModel = StateObject(wrappedValue: MatcheDetailViewModel(match: match))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                matchHeader

                Button {
                    openHighlightsOnYoutube()
                } label: {
                    HStack {
                        Image(systemName: "play.rectangle.fill")
                        Text(String(localized: .watch_highlights_on_youtube))
                            .font(.semibold16)
                        Spacer()
                        Image(systemName: "arrow.up.forward.square")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("primary").opacity(0.9))
                    )
                }
                .buttonStyle(.plain)

                Picker(String(localized: .detail_tabs), selection: $selectedTab) {
                    ForEach(DetailTab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .scaleEffect(y: 1.18)
                .padding(.horizontal, 2)
                .padding(.vertical, 4)

                Group {
                    switch selectedTab {
                    case .lineup:
                        LineUpTab(
                            isLoading: viewModel.isLoading,
                            errorMessage: viewModel.errorMessage,
                            lineups: viewModel.lineups,
                            expandedLineupIDs: $expandedLineupIDs
                        )
                    case .highlight:
                        HighLightTab(
                            isLoading: viewModel.isLoading,
                            errorMessage: viewModel.errorMessage,
                            highlights: viewModel.highlights
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .navigationTitle(String(localized: .match_details_title))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadData()
            expandedLineupIDs = Set(viewModel.lineups.map(\.id))
        }
    }

    private var matchHeader: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                RemoteImage(urlString: viewModel.match.league.logo, size: 16)
                Text(viewModel.match.league.name)
                    .font(.regular14)
                    .foregroundColor(.secondary)
                Spacer()
            }

            HStack(spacing: 14) {
                teamBlock(name: viewModel.match.teams.home.name, logo: viewModel.match.teams.home.logo)
                Text(scoreText)
                    .font(.semibold30)
                    .foregroundColor(Color("primary"))
                teamBlock(name: viewModel.match.teams.away.name, logo: viewModel.match.teams.away.logo)
            }

            Text(statusText)
                .font(.regular14)
                .foregroundColor(.secondary)

            if let venue = viewModel.match.fixture.venue?.name, !venue.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                    Text(venue)
                }
                .font(.regular14)
                .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
    }

    private func teamBlock(name: String, logo: String?) -> some View {
        VStack(spacing: 8) {
            RemoteImage(urlString: logo, size: 58)
            Text(name)
                .font(.semibold16)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 120)
        }
    }

    private var scoreText: String {
        if let home = viewModel.match.goals.home, let away = viewModel.match.goals.away {
            return "\(home) - \(away)"
        }
        return viewModel.match.fixture.status.short
    }

    private var statusText: String {
        let status = viewModel.match.fixture.status.short
        switch status {
        case "FT": return String(localized: .match_finished)
        case "NS": return String(localized: .not_started_format, kickoffText)
        default: return status
        }
    }

    private var kickoffText: String {
        Self.timeFormatter.string(from: viewModel.match.fixture.date)
    }

    private static let timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm dd/MM"
        return df
    }()

    private func openHighlightsOnYoutube() {
        let home = viewModel.match.teams.home.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let away = viewModel.match.teams.away.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let query = "\(home)%20vs%20\(away)%20highlights"
        guard let url = URL(string: "https://www.youtube.com/results?search_query=\(query)") else { return }
        UIApplication.shared.open(url)
    }

}

