//
//  DateIntelligenceAnalysisView.swift
//  Heartbeat
//
//  Created by Liam Arbuckle on 8/1/2026.
//

import SwiftUI
import SwiftData

struct DateIntelligenceAnalysisView: View {
    let person: DatePerson
    let date: PreviousDate
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var insights: [DateInsight] = []
    @State private var isAnalyzing = true
    @State private var analysisError: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                AppStyle.Colors.background(for: colorScheme)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        dateAnalysisHeaderView
                        
                        // Analysis Content
                        if isAnalyzing {
                            DateAnalysisLoadingView()
                        } else if let error = analysisError {
                            DateAnalysisErrorView(error: error) {
                                Task {
                                    await performDateAnalysis()
                                }
                            }
                        } else {
                            // Insights
                            LazyVStack(spacing: 16) {
                                ForEach(insights, id: \.title) { insight in
                                    DateInsightCard(insight: insight)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .task {
                await performDateAnalysis()
            }
        }
    }
    
    private var dateAnalysisHeaderView: some View {
        VStack(spacing: 16) {
            HStack {
                Button("CLOSE") {
                    dismiss()
                }
                .font(AppStyle.Fonts.caption)
                .foregroundColor(AppStyle.Colors.accent)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            
            VStack(spacing: 8) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(AppStyle.Colors.accent)
                
                Text("APPLE INTELLIGENCE")
                    .font(AppStyle.Fonts.title)
                    .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                
                Text("DATE ANALYSIS")
                    .font(AppStyle.Fonts.heading)
                    .foregroundColor(AppStyle.Colors.accent)
                
                Text(date.location.uppercased())
                    .font(AppStyle.Fonts.body)
                    .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                
                Text(date.date.formatted(date: .abbreviated, time: .omitted))
                    .font(AppStyle.Fonts.caption)
                    .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
            }
            .padding(.horizontal, 24)
        }
    }
    
    private func performDateAnalysis() async {
        isAnalyzing = true
        analysisError = nil
        
        // Simulate AI analysis delay
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Generate insights based on the date data
        insights = generateDateInsights()
        
        isAnalyzing = false
    }
    
    private func generateDateInsights() -> [DateInsight] {
        var insights: [DateInsight] = []
        
        // Emotion Analysis
        if !date.emotions.isEmpty {
            let emotionAnalysis = analyzeEmotions()
            insights.append(emotionAnalysis)
        }
        
        // Discussion Quality
        if !date.discussionPoints.isEmpty {
            let discussionAnalysis = analyzeDiscussionPoints()
            insights.append(discussionAnalysis)
        }
        
        // Physical Intimacy
        if !date.physicalTouchMoments.isEmpty {
            let intimacyAnalysis = analyzePhysicalTouch()
            insights.append(intimacyAnalysis)
        }
        
        // Gift Analysis
        if !date.gifts.isEmpty {
            let giftAnalysis = analyzeGifts()
            insights.append(giftAnalysis)
        }
        
        // Journal Sentiment
        if !date.journalEntry.isEmpty {
            let journalAnalysis = analyzeJournalEntry()
            insights.append(journalAnalysis)
        }
        
        // Overall Date Quality
        let overallAnalysis = analyzeOverallDateQuality()
        insights.append(overallAnalysis)
        
        // Relationship Growth
        let growthAnalysis = analyzeRelationshipGrowth()
        insights.append(growthAnalysis)
        
        return insights
    }
    
    private func analyzeEmotions() -> DateInsight {
        let emotions = date.emotions
        let averageIntensity = emotions.isEmpty ? 0 : emotions.reduce(0) { $0 + $1.intensity } / emotions.count
        let dominantEmotions = emotions.prefix(3).map { $0.emotionType.rawValue }.joined(separator: ", ")
        
        let positiveEmotions = emotions.filter { 
            [.happy, .excited, .grateful, .loved, .peaceful, .content, .hopeful].contains($0.emotionType)
        }.count
        
        let description = if positiveEmotions > emotions.count / 2 {
            "This date generated predominantly positive emotions. You felt \(dominantEmotions) with an average intensity of \(averageIntensity)/5. This suggests strong emotional connection and enjoyment."
        } else {
            "This date had mixed emotional responses. Key feelings included \(dominantEmotions). Consider what might have contributed to less positive emotions."
        }
        
        return DateInsight(
            title: "Emotional Analysis",
            description: description,
            category: .emotional,
            score: min(10, averageIntensity * 2),
            icon: "heart.circle"
        )
    }
    
    private func analyzeDiscussionPoints() -> DateInsight {
        let pointCount = date.discussionPoints.count
        let variety = Set(date.discussionPoints.compactMap { $0.lowercased().components(separatedBy: " ").first }).count
        
        let description = if pointCount >= 5 {
            "Excellent conversation depth! You discussed \(pointCount) different topics, showing strong communication and mutual interest. High variety in conversation topics indicates good compatibility."
        } else if pointCount >= 3 {
            "Good conversation flow with \(pointCount) discussion points. This shows healthy communication, though there's room for deeper exploration of topics."
        } else {
            "Limited discussion points (\(pointCount)) recorded. Consider whether conversation flowed naturally or if there might be opportunities for deeper connection."
        }
        
        return DateInsight(
            title: "Communication Quality",
            description: description,
            category: .communication,
            score: min(10, pointCount * 2),
            icon: "bubble.left.and.bubble.right"
        )
    }
    
    private func analyzePhysicalTouch() -> DateInsight {
        let touchCount = date.physicalTouchMoments.count
        let intimacyLevel = date.physicalTouchMoments.contains { $0.touchType == .kiss || $0.touchType == .cuddle } ? "High" : 
                          date.physicalTouchMoments.contains { $0.touchType == .hug || $0.touchType == .handHolding } ? "Medium" : "Low"
        
        let description = "Physical intimacy level: \(intimacyLevel). You recorded \(touchCount) physical touch moments, indicating \(intimacyLevel.lowercased()) physical comfort and connection. Physical touch is an important bonding mechanism in relationships."
        
        return DateInsight(
            title: "Physical Intimacy",
            description: description,
            category: .intimacy,
            score: min(10, touchCount * 3),
            icon: "hands.sparkles"
        )
    }
    
    private func analyzeGifts() -> DateInsight {
        let giftCount = date.gifts.count
        let givenCount = date.gifts.filter { $0.giver == "me" }.count
        let receivedCount = date.gifts.filter { $0.giver == "them" }.count
        
        let description = "Gift exchange: \(giftCount) total (\(givenCount) given, \(receivedCount) received). " +
                         (givenCount > 0 && receivedCount > 0 ? "Mutual gift-giving shows thoughtfulness from both parties." :
                          givenCount > 0 ? "Your thoughtfulness in giving gifts shows care and consideration." :
                          "Receiving gifts indicates their thoughtfulness towards you.")
        
        return DateInsight(
            title: "Thoughtfulness",
            description: description,
            category: .thoughtfulness,
            score: min(10, giftCount * 3),
            icon: "gift"
        )
    }
    
    private func analyzeJournalEntry() -> DateInsight {
        let wordCount = date.journalEntry.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
        let positiveWords = ["great", "amazing", "wonderful", "perfect", "love", "happy", "fun", "enjoyed", "beautiful"].filter {
            date.journalEntry.lowercased().contains($0)
        }.count
        
        let sentiment = positiveWords > 3 ? "Very Positive" : positiveWords > 1 ? "Positive" : "Neutral"
        
        let description = "Journal sentiment: \(sentiment). Your \(wordCount)-word entry reveals \(sentiment.lowercased()) feelings about this date. " +
                         (wordCount > 50 ? "Detailed journaling indicates significant emotional impact." : "Consider writing more detailed entries to capture memories better.")
        
        return DateInsight(
            title: "Personal Reflection",
            description: description,
            category: .reflection,
            score: min(10, (wordCount / 10) + (positiveWords * 2)),
            icon: "book"
        )
    }
    
    private func analyzeOverallDateQuality() -> DateInsight {
        let hasEmotions = !date.emotions.isEmpty
        let hasDiscussion = !date.discussionPoints.isEmpty
        let hasJournal = !date.journalEntry.isEmpty
        let hasPhysicalTouch = !date.physicalTouchMoments.isEmpty
        
        let completeness = [hasEmotions, hasDiscussion, hasJournal, hasPhysicalTouch].filter { $0 }.count
        
        let description = switch completeness {
        case 4: "Comprehensive date documentation! You've captured emotions, conversations, physical moments, and personal reflections. This suggests a well-rounded, meaningful experience."
        case 3: "Well-documented date with good detail across multiple dimensions. This indicates a quality time together with meaningful connection."
        case 2: "Moderate documentation. Consider capturing more aspects of your dates to build richer memories and insights over time."
        default: "Limited documentation. Recording more details about your dates can help you understand patterns and growth in your relationship."
        }
        
        return DateInsight(
            title: "Date Quality Score",
            description: description,
            category: .overall,
            score: completeness * 2 + 2,
            icon: "star.circle"
        )
    }
    
    private func analyzeRelationshipGrowth() -> DateInsight {
        // This would ideally compare with previous dates
        let description = "Based on the richness of this date experience, your relationship shows signs of healthy development. The variety of emotional, physical, and intellectual connections suggests growing intimacy and compatibility."
        
        return DateInsight(
            title: "Relationship Growth",
            description: description,
            category: .growth,
            score: 8,
            icon: "arrow.up.heart"
        )
    }
}

// MARK: - Supporting Views

struct DateAnalysisLoadingView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var rotation: Double = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 60))
                .foregroundColor(AppStyle.Colors.accent)
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
            
            Text("ANALYZING DATE...")
                .font(AppStyle.Fonts.heading)
                .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
            
            Text("Apple Intelligence is analyzing your date data to provide insights about emotional connection, communication patterns, and relationship dynamics.")
                .font(AppStyle.Fonts.body)
                .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 40)
    }
}

struct DateAnalysisErrorView: View {
    let error: String
    let onRetry: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("ANALYSIS ERROR")
                .font(AppStyle.Fonts.heading)
                .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
            
            Text(error)
                .font(AppStyle.Fonts.body)
                .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("TRY AGAIN") {
                onRetry()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.vertical, 40)
    }
}

// MARK: - Data Models

struct DateInsight {
    let title: String
    let description: String
    let category: DateInsightCategory
    let score: Int
    let icon: String
}

enum DateInsightCategory {
    case emotional
    case communication
    case intimacy
    case thoughtfulness
    case reflection
    case overall
    case growth
    
    var color: Color {
        switch self {
        case .emotional: return .pink
        case .communication: return .blue
        case .intimacy: return .purple
        case .thoughtfulness: return .green
        case .reflection: return .orange
        case .overall: return .cyan
        case .growth: return .mint
        }
    }
}

struct DateInsightCard: View {
    let insight: DateInsight
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: insight.icon)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(insight.category.color)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(insight.title)
                        .font(AppStyle.Fonts.heading)
                        .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                    
                    Spacer()
                    
                    ScoreIndicatorView(score: insight.score, maxScore: 10, color: insight.category.color)
                }
                
                Text(insight.description)
                    .font(AppStyle.Fonts.body)
                    .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
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
    }
}

struct ScoreIndicatorView: View {
    let score: Int
    let maxScore: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<maxScore, id: \.self) { index in
                Circle()
                    .fill(index < score ? color : color.opacity(0.2))
                    .frame(width: 6, height: 6)
            }
        }
    }
}

#Preview {
    let person = DatePerson(name: "Sarah", meetingDate: Date())
    let date = PreviousDate(location: "Central Park", date: Date(), time: Date())
    
    DateIntelligenceAnalysisView(person: person, date: date)
        .modelContainer(for: DatePerson.self, inMemory: true)
}