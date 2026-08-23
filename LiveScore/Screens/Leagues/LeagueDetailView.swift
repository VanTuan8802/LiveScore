//
//  LeagueDetailView.swift
//  LiveScore
//

import SwiftUI
import Factory

struct LeagueDetailView: View {
    let leagueId: Int
    let leagueName: String

    @StateObject private var viewModel: LeagueDetailViewModel
    @InjectedObject(\.app) private var app: AppManager

    init(leagueId: Int, leagueName: String) {
        self.leagueId = leagueId
        self.leagueName = leagueName
        _viewModel = StateObject(wrappedValue: LeagueDetailViewModel(leagueId: leagueId))
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView(String(localized: .loading))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 12) {
                    Text(String(localized: .errorTitle))
                        .font(.semibold20)
                    Text(errorMessage)
                        .font(.regular14)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    Button(String(localized: .retryAction)) {
                        Task { await viewModel.load() }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        roundController

                        if viewModel.isLoadingRound {
                            ProgressView(String(localized: .loading))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 24)
                        } else if viewModel.selectedRoundFixtures.isEmpty {
                            Text("No fixtures in this round.")
                                .font(.regular14)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 24)
                        } else {
                            ForEach(viewModel.selectedRoundFixtures) { match in
                                Button {
                                    app.navi.push(.matcheDetail(match: match))
                                } label: {
                                    CompactMatchRow(match: match)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                }
                                .buttonStyle(.plain)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                )
                            }
                        }
                    }
                    .padding(16)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.95, green: 0.98, blue: 0.95))
        .safeAreaInset(edge: .top, spacing: 0) {
            HeaderView(title: leagueName, showBack: true)
        }
        .task { await viewModel.load() }
    }

    private var roundController: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Current Round")
                .font(.semibold16)

            HStack {
                Button("Previous") {
                    viewModel.goPreviousRound()
                }
                .disabled(!viewModel.canGoPrevious)

                Spacer()

                Text(viewModel.selectedRoundTitle)
                    .font(.semibold14)
                    .multilineTextAlignment(.center)

                Spacer()

                Button("Next") {
                    viewModel.goNextRound()
                }
                .disabled(!viewModel.canGoNext)
            }
            .font(.regular14)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
            )
        }
    }
}

#Preview {
    LeagueDetailView(leagueId: 39, leagueName: "Premier League")
}

