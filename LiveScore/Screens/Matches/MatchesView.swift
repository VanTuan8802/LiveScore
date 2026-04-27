//
//  MatchesView.swift
//  LiveScore
//
//  Created by VanTuan8802 on 19/4/26.
//

import SwiftUI

struct MatchesView: View {
    @StateObject private var viewModel = MatchesViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Text("Error")
                            .font(.semibold20)
                        Text(errorMessage)
                            .font(.regular14)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 24)
                        Button("Retry") { Task { await viewModel.loadMatches() } }
                            .font(.semibold14)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.matches.isEmpty {
                    Text("No matches today.")
                        .font(.regular16)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0, pinnedViews: []) {
                            ForEach(groupedMatches) { section in
                                VStack(spacing: 0) {
                                    LeagueHeaderView(section: section)
                                    ForEach(Array(section.matches.enumerated()), id: \.element.id) { index, match in
                                        MatchRow(match: match)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                        if index < section.matches.count - 1 {
                                            Divider()
                                                .padding(.leading, 44)
                                                .padding(.trailing, 16)
                                        }
                                    }
                                }
                                .background(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.systemGray5), lineWidth: 0.8)
                                )
                                .padding(.horizontal, 12)
                                .padding(.top, 10)
                            }
                        }
                    }
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle(Text(String(localized: .matches)))
            .task { await viewModel.loadMatches() }
            .refreshable { await viewModel.loadMatches() }
        }
    }

    private var groupedMatches: [LeagueSection] {
        var sections: [LeagueSection] = []
        for match in viewModel.matches {
            if let index = sections.firstIndex(where: { $0.id == match.league.id }) {
                sections[index].matches.append(match)
            } else {
                sections.append(
                    LeagueSection(
                        id: match.league.id,
                        name: match.league.name,
                        logo: match.league.logo,
                        round: match.league.round,
                        matches: [match]
                    )
                )
            }
        }
        return sections
    }
}

private struct MatchRow: View {
    let match: AFFixtureResponse

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 10) {
                TeamVerticalRowView(
                    displayName: "\(match.teams.home.name) (\(String(localized: "home_short")))",
                    logoURL: match.teams.home.logo
                )
                TeamVerticalRowView(
                    displayName: "\(match.teams.away.name) (\(String(localized: "away_short")))",
                    logoURL: match.teams.away.logo
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 10) {
                Text(kickoffText)
                    .font(.regular14)
                    .foregroundColor(.secondary)
                    .frame(width: 44, alignment: .trailing)

                Text(scoreText)
                    .font(.semibold14)
                    .foregroundColor(.primary)
                    .frame(minWidth: 34)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color(.systemGray6))
                    )
            }
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
    }

    private var scoreText: String {
        let home = match.goals.home
        let away = match.goals.away
        if let home, let away {
            return "\(home) - \(away)"
        }
        return match.fixture.status.short
    }

    private var kickoffText: String {
        Self.timeFormatter.string(from: match.fixture.date)
    }

    private static let timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        return df
    }()
}

private struct LeagueHeaderView: View {
    let section: LeagueSection

    var body: some View {
        HStack(spacing: 10) {
            RemoteImage(urlString: section.logo, size: 18)
                .frame(width: 26, height: 26)
                .background(Color.white.opacity(0.85))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            HStack(spacing: 4) {
                Text(section.name)
                    .font(.semibold16)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text("(\(roundDisplay))")
                    .font(.regular12)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            Spacer(minLength: 8)

            Text("->")
                .font(.semibold20)
                .foregroundColor(.white)
                .frame(minWidth: 28, alignment: .trailing)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("primary").opacity(0.14))
        )
    }

    private var roundDisplay: String {
        guard let round = section.round, !round.isEmpty else {
            return "Round -"
        }

        let digits = round.filter(\.isNumber)
        if !digits.isEmpty {
            return "Round \(digits)"
        }

        return round
    }
}

private struct TeamVerticalRowView: View {
    let displayName: String
    let logoURL: String?

    var body: some View {
        HStack(spacing: 8) {
            RemoteImage(urlString: logoURL, size: 20)
            Text(displayName)
                .font(.semibold14)
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }
}

private struct RemoteImage: View {
    let urlString: String?
    let size: CGFloat

    var body: some View {
        if let urlString, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure:
                    placeholder
                case .empty:
                    placeholder
                @unknown default:
                    placeholder
                }
            }
            .frame(width: size, height: size)
        } else {
            placeholder
                .frame(width: size, height: size)
        }
    }

    private var placeholder: some View {
        Circle()
            .fill(Color(.systemGray5))
            .overlay(
                Circle()
                    .stroke(Color(.systemGray4), lineWidth: 0.5)
            )
    }
}

private struct LeagueSection: Identifiable {
    let id: Int
    let name: String
    let logo: String?
    let round: String?
    var matches: [AFFixtureResponse]
}

#Preview {
    MatchesView()
}
