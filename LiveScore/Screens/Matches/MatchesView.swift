//
//  MatchesView.swift
//  LiveScore
//
//  Created by VanTuan8802 on 19/4/26.
//

import SwiftUI

struct MatchesView: View {
    @StateObject private var viewModel = MatchesViewModel()
    @State private var selectedLeagueId: Int?
    @State private var selectedDate: Date = Date()
    @State private var showDatePicker: Bool = false
    private let preferredLeagueIDs: [Int] = [1, 4, 2, 39, 140, 135, 78, 61]

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
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 18) {
                            WeekSelector(
                                selectedDate: $selectedDate,
                                onTapCalendar: { showDatePicker = true }
                            )
                            .padding(.top, 6)

                            if let liveMatch {
                                Text("Live Match")
                                    .font(.semibold20)
                                LiveMatchCard(match: liveMatch)
                            }

                            Text("Today Match")
                                .font(.semibold20)

                            LeagueChipSelector(
                                leagues: groupedMatches,
                                selectedLeagueId: $selectedLeagueId
                            )

                            VStack(spacing: 12) {
                                ForEach(filteredSections) { section in
                                    VStack(spacing: 0) {
                                        LeagueHeaderView(section: section)
                                        ForEach(Array(section.matches.enumerated()), id: \.element.id) { index, match in
                                            CompactMatchRow(match: match)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 10)
                                            if index < section.matches.count - 1 {
                                                Divider()
                                                    .padding(.horizontal, 12)
                                            }
                                        }
                                    }
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color(.systemGray5), lineWidth: 0.8)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    }
                    .background(
                        LinearGradient(
                            colors: [Color(.systemGray6), Color.white],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea()
                    )
                }
            }
            .navigationBarHidden(true)
            .task { await viewModel.loadMatches(for: selectedDate) }
            .refreshable { await viewModel.loadMatches(for: selectedDate) }
            .onChange(of: selectedDate) { _, newValue in
                Task { await viewModel.loadMatches(for: newValue) }
            }
            .sheet(isPresented: $showDatePicker) {
                NavigationStack {
                    VStack {
                        DatePicker(
                            "Select date",
                            selection: $selectedDate,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.graphical)
                        .padding()
                        Spacer()
                    }
                    .navigationTitle("Choose date")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") { showDatePicker = false }
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }

    private var groupedMatches: [LeagueSection] {
        let priorityMap = Dictionary(uniqueKeysWithValues: preferredLeagueIDs.enumerated().map { ($1, $0) })
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
        return sections.sorted { lhs, rhs in
            let lhsPriority = priorityMap[lhs.id] ?? Int.max
            let rhsPriority = priorityMap[rhs.id] ?? Int.max
            if lhsPriority != rhsPriority {
                return lhsPriority < rhsPriority
            }
            return lhs.name < rhs.name
        }
    }

    private var filteredSections: [LeagueSection] {
        guard let selectedLeagueId else { return groupedMatches }
        return groupedMatches.filter { $0.id == selectedLeagueId }
    }

    private var liveMatch: AFFixtureResponse? {
        viewModel.matches.first {
            ["LIVE", "1H", "2H", "HT"].contains($0.fixture.status.short)
        } ?? viewModel.matches.first
    }
}

#Preview {
    MatchesView()
}
