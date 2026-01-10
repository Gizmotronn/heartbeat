//
//  EmptyStateView.swift
//  Heartbeat
//
//  Created by Liam Arbuckle on 8/1/2026.
//

import SwiftUI

struct EmptyStateView: View {
    @Binding var showingOnboarding: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("💕")
                    .font(.system(size: 80))
                
                Text("READY FOR YOUR\nFIRST DATE NIGHT?")
                    .font(AppStyle.Fonts.title)
                    .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                    .multilineTextAlignment(.center)
                
                Text("Let's add your special someone and start tracking those magical moments together.")
                    .font(AppStyle.Fonts.body)
                    .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            Button("START YOUR FIRST DATE NIGHT") {
                showingOnboarding = true
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
}