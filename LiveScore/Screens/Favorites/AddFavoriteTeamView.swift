//
//  AddFavoriteTeamView.swift
//  LiveScore
//

import SwiftUI
import Factory

struct AddFavoriteTeamView: View {
    @InjectedObject(\.favoritesStore) private var store: FavoritesStore
    @StateObject private var viewModel = AddFavoriteTeamViewModel()

    var body: some View {
        VStack(spacing: 0) {
            if !viewModel.leagues.isEmpty {
                leagueChips
                searchBar
            }
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.95, green: 0.98, blue: 0.95))
        .safeAreaInset(edge: .top, spacing: 0) {
            HeaderView(title: String(localized: .addFavoriteTeam), showBack: true)
        }
        .task { await viewModel.loadLeaguesIfNeeded() }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoadingLeagues || viewModel.isLoadingTeams {
            ProgressView(String(localized: .loading))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.filteredTeams.isEmpty {
            Text(String(localized: .noTeamsFound))
                .font(.regular16)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filteredTeams, id: \.id) { team in
                        teamRow(team)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
        }
    }

    private var leagueChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.leagues, id: \.league.id) { item in
                    let isSelected = viewModel.selectedLeagueId == item.league.id
                    Button {
                        Task { await viewModel.selectLeague(item.league.id) }
                    } label: {
                        HStack(spacing: 6) {
                            RemoteImage(urlString: item.league.logo, size: 18)
                            Text(item.league.name)
                                .font(.semibold14)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .foregroundColor(isSelected ? .white : .primary)
                        .background(
                            Capsule().fill(isSelected ? Color("primary") : Color.white)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundColor(.gray)
            TextField(String(localized: .searchTeams), text: $viewModel.searchText)
                .font(.regular16)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.gray.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 4)
    }

    private func teamRow(_ team: AFTeamSummary) -> some View {
        let isFav = store.isFavorite(team.id)
        return Button {
            store.toggle(FavoriteTeam(id: team.id, name: team.name, logo: team.logo))
        } label: {
            HStack(spacing: 12) {
                RemoteImage(urlString: team.logo, size: 40)
                Text(team.name)
                    .font(.semibold16)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Spacer()
                Image(systemName: isFav ? "star.fill" : "star")
                    .font(.system(size: 20))
                    .foregroundColor(isFav ? .yellow : .gray.opacity(0.6))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
