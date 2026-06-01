//
//  HeaderView.swift
//  LiveScore
//
//  Created by VanTuan8802 on 1/5/26.
//

import SwiftUI
import Factory

struct HeaderView<Right: View>: View {
    @InjectedObject(\.app) private var app: AppManager

    let title: String
    var showBack: Bool = false
    var leftAction: (() -> Void)? = nil
    @ViewBuilder var rightView: () -> Right
    var rightAction: (() -> Void)? = nil
    var rightActionSystemImage: String = "ellipsis.circle"

    init(
        title: String,
        showBack: Bool = false,
        leftAction: (() -> Void)? = nil,
        rightAction: (() -> Void)? = nil,
        rightActionSystemImage: String = "ellipsis.circle",
        @ViewBuilder rightView: @escaping () -> Right = { EmptyView() }
    ) {
        self.title = title
        self.showBack = showBack
        self.leftAction = leftAction
        self.rightAction = rightAction
        self.rightActionSystemImage = rightActionSystemImage
        self.rightView = rightView
    }

    var body: some View {
        HStack(spacing: 8) {
            leftBar
            titleText
            rightBar
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color("primary"))
    }

    @ViewBuilder
    private var leftBar: some View {
        HStack(spacing: 4) {
            if showBack {
                Button(action: handleBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.black)
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(minWidth: 44, alignment: .leading)
    }

    private var titleText: some View {
        Text(title)
            .font(.semibold24)
            .foregroundStyle(Color.black)
            .lineLimit(1)
            .minimumScaleFactor(0.85)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    private var rightBar: some View {
        HStack(spacing: 4) {
            rightView()
            if let rightAction {
                Button(action: rightAction) {
                    Image(systemName: rightActionSystemImage)
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(Color.black)
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(minWidth: 44, alignment: .trailing)
    }

    private func handleBack() {
        if let leftAction {
            leftAction()
        } else {
            app.navi.pop()
        }
    }
}

#Preview("Back + title") {
    VStack(spacing: 0) {
        HeaderView(title: "Leagues", showBack: true, leftAction: {})
        Spacer()
    }
}

#Preview("Title + right") {
    VStack(spacing: 0) {
        HeaderView(
            title: "Matches",
            rightAction: {},
            rightView: { Image(systemName: "bell").foregroundStyle(.secondary) }
        )
        Spacer()
    }
}

