//
//  IntelligenceHeaderView.swift
//  Heartbeat
//
//  Created by Liam Arbuckle on 8/1/2026.
//

import SwiftUI

struct IntelligenceHeaderView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            Text("🧠")
                .font(.system(size: 60))
            
            Text("APPLE INTELLIGENCE")
                .font(AppStyle.Fonts.heading)
                .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
            
            Text("RELATIONSHIP OVERVIEW")
                .font(AppStyle.Fonts.title)
                .foregroundColor(AppStyle.Colors.accent)
            
            Text("Insights about your relationship")
                .font(AppStyle.Fonts.body)
                .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top)
    }
}