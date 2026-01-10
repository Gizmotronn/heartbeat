//
//  PreviousDatesView.swift
//  Heartbeat
//
//  Created by Liam Arbuckle on 8/1/2026.
//

import SwiftUI

struct UpcomingDatesView: View {
    let person: DatePerson
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("UPCOMING DATES")
                .font(AppStyle.Fonts.heading)
                .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
            
            let upcomingDates = person.previousDates.filter { $0.fullDateTime > Date() }.sorted(by: { $0.fullDateTime < $1.fullDateTime })
            ForEach(upcomingDates) { upcomingDate in
                UpcomingDateCardView(upcomingDate: upcomingDate, person: person)
            }
        }
    }
}

struct UpcomingDateCardView: View {
    let upcomingDate: PreviousDate
    let person: DatePerson
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingEditDate = false
    
    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(upcomingDate.effectiveDateType.accentColor)
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 12) {
                Button(action: {
                    if upcomingDate.canOpenInMaps {
                        upcomingDate.openInAppleMaps()
                    }
                }) {
                    HStack {
                        Text(upcomingDate.location.uppercased())
                            .font(AppStyle.Fonts.body)
                            .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                        Spacer()
                        if upcomingDate.canOpenInMaps {
                            Image(systemName: "map.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppStyle.Colors.accent)
                        } else {
                            Image(systemName: "location.slash")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(!upcomingDate.canOpenInMaps)
                
                HStack {
                    Text(upcomingDate.date.formatted(date: .abbreviated, time: .omitted).uppercased())
                        .font(AppStyle.Fonts.caption)
                        .foregroundColor(AppStyle.Colors.accent)
                    
                    Text("•")
                        .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                    
                    Text(upcomingDate.time.formatted(date: .omitted, time: .shortened))
                        .font(AppStyle.Fonts.caption)
                        .foregroundColor(AppStyle.Colors.accent)
                    
                    if !upcomingDate.notes.isEmpty {
                        Text("•")
                            .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                        
                        Text(upcomingDate.notes)
                            .font(AppStyle.Fonts.caption)
                            .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Button("EDIT") {
                        showingEditDate = true
                    }
                    .font(AppStyle.Fonts.caption)
                    .foregroundColor(AppStyle.Colors.accent)
                }
            }
            .padding(12)
        }
        .background(AppStyle.Colors.surface(for: colorScheme))
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
        .sheet(isPresented: $showingEditDate) {
            EditDateView(person: person, dateToEdit: upcomingDate)
        }
    }
}

struct PreviousDatesView: View {
    let person: DatePerson
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("PREVIOUS DATES")
                .font(AppStyle.Fonts.heading)
                .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
            
            let pastDates = person.previousDates.filter { $0.fullDateTime <= Date() }.sorted(by: { $0.fullDateTime > $1.fullDateTime })
            ForEach(pastDates) { previousDate in
                DateCardView(previousDate: previousDate, person: person)
            }
        }
    }
}

struct DateCardView: View {
    let previousDate: PreviousDate
    let person: DatePerson
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingEditDate = false
    @State private var showingDateDetail = false
    
    // Compute emotion gradient colors (Apple Card style)
    private var emotionGradient: LinearGradient {
        let emotions = previousDate.emotions
        
        if emotions.isEmpty {
            // Default white/surface background when no emotions
            return LinearGradient(
                colors: [AppStyle.Colors.surface(for: colorScheme)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        // Get unique emotion colors, weighted by intensity
        var gradientColors: [Color] = []
        
        // Sort emotions by intensity (highest first) and take unique colors
        let sortedEmotions = emotions.sorted { $0.intensity > $1.intensity }
        var seenTypes: Set<String> = []
        
        for emotion in sortedEmotions {
            if !seenTypes.contains(emotion.emotionType.rawValue) {
                // Use a lighter version for the card background
                gradientColors.append(emotion.emotionType.color.opacity(0.25))
                seenTypes.insert(emotion.emotionType.rawValue)
            }
            if gradientColors.count >= 4 { break } // Max 4 colors like Apple Card
        }
        
        // If only one color, duplicate it for a subtle single-color gradient
        if gradientColors.count == 1 {
            gradientColors.append(gradientColors[0].opacity(0.5))
        }
        
        return LinearGradient(
            colors: gradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        Button(action: {
            // Only show detail view for past dates
            if previousDate.fullDateTime <= Date() {
                showingDateDetail = true
            } else {
                showingEditDate = true
            }
        }) {
            HStack(spacing: 0) {
                Rectangle()
                    .fill(previousDate.effectiveDateType.accentColor)
                    .frame(width: 4)
                
                VStack(alignment: .leading, spacing: 12) {
                    Button(action: {
                        if previousDate.canOpenInMaps {
                            previousDate.openInAppleMaps()
                        }
                    }) {
                        HStack {
                            Text(previousDate.location.uppercased())
                                .font(AppStyle.Fonts.body)
                                .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                            Spacer()
                            if previousDate.canOpenInMaps {
                                Image(systemName: "map.fill")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(AppStyle.Colors.accent)
                            } else {
                                Image(systemName: "location.slash")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(!previousDate.canOpenInMaps)
                    
                    HStack {
                        Text(previousDate.date.formatted(date: .abbreviated, time: .omitted).uppercased())
                            .font(AppStyle.Fonts.caption)
                            .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                        
                        Text("•")
                            .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                        
                        Text(previousDate.time.formatted(date: .omitted, time: .shortened))
                            .font(AppStyle.Fonts.caption)
                            .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                        
                        if !previousDate.notes.isEmpty {
                            Text("•")
                                .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                            
                            Text(previousDate.notes)
                                .font(AppStyle.Fonts.caption)
                                .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        // Show different text based on whether it's past or future
                        Text(previousDate.fullDateTime <= Date() ? "VIEW DETAILS" : "EDIT")
                            .font(AppStyle.Fonts.caption)
                            .foregroundColor(AppStyle.Colors.accent)
                    }
                }
                .padding(12)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .background(emotionGradient)
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
        .sheet(isPresented: $showingEditDate) {
            EditDateView(person: person, dateToEdit: previousDate)
        }
        .sheet(isPresented: $showingDateDetail) {
            DateDetailView(person: person, date: previousDate)
        }
    }
}
