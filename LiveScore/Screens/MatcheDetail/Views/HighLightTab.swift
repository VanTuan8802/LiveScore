//
//  HighLightTab.swift
//  LiveScore
//
//  Created by VanTuan8802 on 30/4/26.
//

import SwiftUI

struct HighLightTab: View {
    let isLoading: Bool
    let errorMessage: String?
    let highlights: [AFFixtureEvent]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if isLoading {
                ProgressView("Loading highlights...")
            } else if let errorMessage {
                Text(errorMessage)
                    .font(.regular14)
                    .foregroundColor(.secondary)
            } else if highlights.isEmpty {
                Text("No highlight events available.")
                    .font(.regular14)
                    .foregroundColor(.secondary)
            } else {
                ForEach(highlights) { event in
                    HStack(alignment: .center, spacing: 10) {
                        Text("\(event.time.elapsed ?? 0)'")
                            .font(.semibold14)
                            .foregroundColor(Color("primary"))
                            .frame(width: 44, alignment: .center)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(event.detail ?? event.type ?? "Event")
                                .font(.semibold14)
                            Text(event.player?.name ?? "-")
                                .font(.regular14)
                                .foregroundColor(.secondary)
                            if let assist = event.assist?.name, !assist.isEmpty {
                                Text("Assist: \(assist)")
                                    .font(.regular12)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                }
            }
        }
    }
}

#Preview {
    HighLightTab(isLoading: false, errorMessage: nil, highlights: [])
}
