//
//  LeaguesView.swift
//  LiveScore
//
//  Created by VanTuan8802 on 19/4/26.
//

import SwiftUI
import Factory

struct LeaguesView: View {
    @StateObject private var viewModel = LeaguesViewModel()
    @InjectedObject(\.app) private var app: AppManager

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
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 24)
                    Button(String(localized: .retryAction)) {
                        Task { await viewModel.loadLeagues(force: true) }
                    }
                    .font(.semibold14)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 0) {
                    searchBar

                    if viewModel.leagues.isEmpty {
                        Text(String(localized: viewModel.isSearching ? .noLeaguesFound : .noLeaguesAvailable))
                            .font(.regular16)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.leagues, id: \.league.id) { item in
                                    leagueRow(item)
                                        .onAppear {
                                            viewModel.loadMoreIfNeeded(currentItem: item)
                                        }
                                }

                                if viewModel.isLoadingMore {
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                        .refreshable { await viewModel.loadLeagues(force: true) }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.95, green: 0.98, blue: 0.95))
        .safeAreaInset(edge: .top, spacing: 0) {
            HeaderView(title: String(localized: .leagues))
        }
        .task { await viewModel.loadIfNeeded() }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.gray)
            TextField(String(localized: .searchLeagues), text: $viewModel.searchText)
                .font(.regular16)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 4)
    }

    private func leagueRow(_ item: AFLeagueResponse) -> some View {
        Button {
            app.navi.push(.leagueDetail(leagueId: item.league.id, leagueName: item.league.name))
        } label: {
            HStack(spacing: 12) {
                RemoteImage(urlString: item.league.logo, size: 42)
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.league.name)
                        .font(.semibold20)
                        .lineLimit(1)
                    if let country = item.country?.name, !country.isEmpty {
                        Text(country)
                            .font(.regular14)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.gray.opacity(0.9))
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

#Preview {
    LeaguesView()
}
