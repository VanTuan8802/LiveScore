//
//  SplashView.swift
//  LiveScore
//
//  Created by VanTuan8802 on 19/4/26.
//

import SwiftUI

struct SplashView: View {
    private var onCompleted: (() -> Void)?
    
    init(onCompleted: (() -> Void)? = nil) {
        self.onCompleted = onCompleted
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(.splashIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            HStack {
                Text(String(localized: .live_score_title))
                    .font(.extraBold22)
                    .foregroundColor(.primary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                onCompleted?()
            }
        }
    }
}

#Preview {
    SplashView()
}
