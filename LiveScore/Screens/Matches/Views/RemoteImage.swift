//
//  RemoteImage.swift
//  LiveScore
//

import SwiftUI

struct RemoteImage: View {
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

