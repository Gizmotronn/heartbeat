//
//  InsightCard.swift
//  Heartbeat
//
//  Created by Liam Arbuckle on 8/1/2026.
//

import SwiftUI

struct RelationshipInsight {
    let icon: String
    let title: String
    let description: String
}

struct InsightCard: View {
    let insight: RelationshipInsight
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text(insight.icon)
                .font(.system(size: 40))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(insight.title)
                    .font(AppStyle.Fonts.title)
                    .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                
                Text(insight.description)
                    .font(AppStyle.Fonts.body)
                    .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(20)
        .background(AppStyle.Colors.surface(for: colorScheme))
        .overlay {
            Rectangle()
                .stroke(AppStyle.Colors.borderColor, lineWidth: AppStyle.Layout.borderWidth)
        }
        .shadow(
            color: AppStyle.Colors.shadowColor,
            radius: 0,
            x: AppStyle.Layout.shadowOffset.width,
            y: AppStyle.Layout.shadowOffset.height
        )
    }
}