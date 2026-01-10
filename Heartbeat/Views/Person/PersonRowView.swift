//
//  PersonRowView.swift
//  Heartbeat
//
//  Created by Liam Arbuckle on 8/1/2026.
//

import SwiftUI

struct PersonRowView: View {
    let person: DatePerson
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            // Profile photo or placeholder
            Group {
                if let profileImage = person.profileImage {
                    profileImage
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(AppStyle.Colors.textSecondary(for: colorScheme).opacity(0.3))
                        .overlay {
                            Image(systemName: "person.fill")
                                .font(.system(size: 24, weight: .black))
                                .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                        }
                }
            }
            .frame(width: 60, height: 60)
            .overlay {
                Rectangle()
                    .stroke(AppStyle.Colors.borderColor, lineWidth: AppStyle.Layout.borderWidth)
            }
            .shadow(
                color: AppStyle.Colors.shadowColor,
                radius: 0,
                x: 3,
                y: 3
            )
            
            VStack(alignment: .leading, spacing: 8) {
                Text(person.name)
                    .font(AppStyle.Fonts.body)
                    .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                
                Text("FIRST MET: \(person.meetingDate.formatted(date: .abbreviated, time: .omitted).uppercased())")
                    .font(AppStyle.Fonts.caption)
                    .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
            }
            
            Spacer()
            
            if !person.previousDates.isEmpty {
                Rectangle()
                    .fill(AppStyle.Colors.accent)
                    .frame(width: 80, height: 40)
                    .overlay {
                        Text("\(person.previousDates.count) DATES")
                            .font(AppStyle.Fonts.caption)
                            .foregroundColor(.white)
                    }
                    .overlay {
                        Rectangle()
                            .stroke(AppStyle.Colors.borderColor, lineWidth: 2)
                    }
                    .shadow(
                        color: AppStyle.Colors.shadowColor,
                        radius: 0,
                        x: 2,
                        y: 2
                    )
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .neobrutalistCard()
    }
}