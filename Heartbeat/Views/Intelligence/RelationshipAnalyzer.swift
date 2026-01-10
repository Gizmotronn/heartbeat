//
//  RelationshipAnalyzer.swift
//  Heartbeat
//
//  Created by Liam Arbuckle on 8/1/2026.
//

import Foundation
import Combine

@MainActor
class RelationshipAnalyzer: ObservableObject {
    
    func analyzeRelationship(person: DatePerson) async -> [RelationshipInsight] {
        // Simulate AI analysis with a realistic delay
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Prepare relationship data for analysis
        let relationshipData = prepareAnalysisData(person: person)
        
        // Generate AI-powered insights
        return await generateIntelligentInsights(data: relationshipData)
    }
    
    private func prepareAnalysisData(person: DatePerson) -> RelationshipAnalysisData {
        let dayComponents = Calendar.current.dateComponents([.day], from: person.meetingDate, to: Date())
        let daysTogether = dayComponents.day ?? 0
        let monthsTogether = Calendar.current.dateComponents([.month], from: person.meetingDate, to: Date()).month ?? 0
        
        // Analyze date patterns
        let sortedDates = person.previousDates.map(\.date).sorted()
        var dateIntervals: [Int] = []
        if sortedDates.count >= 2 {
            for i in 1..<sortedDates.count {
                let interval = Calendar.current.dateComponents([.day], from: sortedDates[i-1], to: sortedDates[i]).day ?? 0
                dateIntervals.append(interval)
            }
        }
        
        // Analyze locations
        let locationFrequency = Dictionary(grouping: person.previousDates, by: { $0.location })
            .mapValues { $0.count }
        
        // Analyze notes sentiment and themes
        let notes = person.previousDates.compactMap { $0.notes.isEmpty ? nil : $0.notes }
        
        // Time patterns
        let timePatterns = person.previousDates.map { date in
            Calendar.current.component(.hour, from: date.time)
        }
        
        // Analyze emotions across all dates
        let allEmotions = person.previousDates.flatMap { $0.emotions }
        let emotionFrequency = Dictionary(grouping: allEmotions, by: { $0.emotionType })
            .mapValues { emotions in
                Double(emotions.reduce(0) { $0 + $1.intensity }) / Double(max(1, emotions.count)) // Average intensity
            }
        
        // Analyze gifts
        let allGifts = person.previousDates.flatMap { $0.gifts }
        let givenGifts = allGifts.filter { $0.giver == "me" }.count
        let receivedGifts = allGifts.filter { $0.giver != "me" }.count
        
        // Analyze physical touch moments
        let allTouchMoments = person.previousDates.flatMap { $0.physicalTouchMoments }
        let touchTypeFrequency = Dictionary(grouping: allTouchMoments, by: { $0.touchType }).mapValues { $0.count }
        
        // Analyze discussion points
        let allDiscussionPoints = person.previousDates.flatMap { $0.discussionPoints }
        
        // Analyze journal entries
        let journalEntries = person.previousDates.compactMap { $0.journalEntry.isEmpty ? nil : $0.journalEntry }
        
        // Analyze date types
        let dateTypeFrequency = Dictionary(grouping: person.previousDates, by: { $0.effectiveDateType })
            .mapValues { $0.count }
        
        return RelationshipAnalysisData(
            personName: person.name,
            daysTogether: daysTogether,
            monthsTogether: monthsTogether,
            totalDates: person.previousDates.count,
            dateIntervals: dateIntervals,
            locationFrequency: locationFrequency,
            notes: notes,
            timePatterns: timePatterns,
            phoneNumber: person.phoneNumber,
            emotionFrequency: emotionFrequency,
            givenGifts: givenGifts,
            receivedGifts: receivedGifts,
            touchTypeFrequency: touchTypeFrequency,
            discussionPoints: allDiscussionPoints,
            journalEntries: journalEntries,
            dateTypeFrequency: dateTypeFrequency
        )
    }
    
    private func generateIntelligentInsights(data: RelationshipAnalysisData) async -> [RelationshipInsight] {
        var insights: [RelationshipInsight] = []
        
        // Relationship Timeline Analysis
        insights.append(analyzeRelationshipTimeline(data: data))
        
        // Emotional Connection Analysis
        if let emotionInsight = analyzeEmotionalConnection(data: data) {
            insights.append(emotionInsight)
        }
        
        // Dating Pattern Analysis
        if let patternInsight = analyzeDatingPatterns(data: data) {
            insights.append(patternInsight)
        }
        
        // Location Intelligence
        if let locationInsight = analyzeLocationPatterns(data: data) {
            insights.append(locationInsight)
        }
        
        // Time Preference Analysis
        if let timeInsight = analyzeTimePreferences(data: data) {
            insights.append(timeInsight)
        }
        
        // Gift Exchange Analysis
        if let giftInsight = analyzeGiftExchange(data: data) {
            insights.append(giftInsight)
        }
        
        // Physical Intimacy Analysis
        if let intimacyInsight = analyzePhysicalIntimacy(data: data) {
            insights.append(intimacyInsight)
        }
        
        // Date Type Preferences
        if let dateTypeInsight = analyzeDateTypePreferences(data: data) {
            insights.append(dateTypeInsight)
        }
        
        // Relationship Momentum
        insights.append(analyzeRelationshipMomentum(data: data))
        
        // Memory Analysis
        if let memoryInsight = analyzeMemories(data: data) {
            insights.append(memoryInsight)
        }
        
        // Personalized Recommendations
        insights.append(generatePersonalizedRecommendation(data: data))
        
        return insights
    }
    
    private func analyzeRelationshipTimeline(data: RelationshipAnalysisData) -> RelationshipInsight {
        if data.monthsTogether >= 12 {
            let years = data.monthsTogether / 12
            let remainingMonths = data.monthsTogether % 12
            var timeDescription = "\(years) year\(years > 1 ? "s" : "")"
            if remainingMonths > 0 {
                timeDescription += " and \(remainingMonths) month\(remainingMonths > 1 ? "s" : "")"
            }
            
            return RelationshipInsight(
                icon: "🎊",
                title: "Milestone Achievement",
                description: "Your relationship has flourished for \(timeDescription), with \(data.totalDates) meaningful dates together. This demonstrates a strong foundation built on consistent quality time and shared experiences."
            )
        } else if data.monthsTogether >= 6 {
            return RelationshipInsight(
                icon: "💫",
                title: "Growing Connection",
                description: "After \(data.monthsTogether) months together, your relationship shows beautiful progression with \(data.totalDates) dates. You've moved beyond the honeymoon phase into deeper understanding and connection."
            )
        } else if data.monthsTogether >= 3 {
            return RelationshipInsight(
                icon: "🌱",
                title: "Blossoming Romance",
                description: "Your \(data.monthsTogether)-month journey includes \(data.totalDates) special moments together. This is a crucial period where you're truly getting to know each other's authentic selves."
            )
        } else {
            let weeks = max(1, data.daysTogether / 7)
            return RelationshipInsight(
                icon: "✨",
                title: "Fresh Beginning",
                description: "Your romance is \(weeks) week\(weeks != 1 ? "s" : "") young with \(data.totalDates) dates already. The excitement and discovery phase is in full swing—every moment together reveals something new."
            )
        }
    }
    
    private func analyzeDatingPatterns(data: RelationshipAnalysisData) -> RelationshipInsight? {
        guard data.dateIntervals.count >= 2 else { return nil }
        
        let averageInterval = Double(data.dateIntervals.reduce(0, +)) / Double(data.dateIntervals.count)
        let consistency = calculateConsistency(intervals: data.dateIntervals)
        
        if consistency > 0.8 && averageInterval <= 7 {
            return RelationshipInsight(
                icon: "📱",
                title: "Highly Connected",
                description: "You see each other every \(Int(averageInterval)) days with remarkable consistency. This suggests strong mutual interest and prioritization of your relationship in both your lives."
            )
        } else if consistency > 0.6 && averageInterval <= 14 {
            return RelationshipInsight(
                icon: "⚖️",
                title: "Balanced Rhythm",
                description: "Your dating pattern of every \(Int(averageInterval)) days shows a healthy balance between togetherness and independence. This sustainable pace allows for both connection and personal growth."
            )
        } else if averageInterval > 21 {
            return RelationshipInsight(
                icon: "🌙",
                title: "Quality Over Quantity",
                description: "While you meet less frequently (every \(Int(averageInterval)) days), this suggests you both value meaningful, quality time together rather than casual encounters."
            )
        }
        
        return nil
    }
    
    private func analyzeLocationPatterns(data: RelationshipAnalysisData) -> RelationshipInsight? {
        guard !data.locationFrequency.isEmpty else { return nil }
        
        let sortedLocations = data.locationFrequency.sorted { $0.value > $1.value }
        let uniqueLocations = data.locationFrequency.count
        let totalDates = data.totalDates
        
        if let favorite = sortedLocations.first, favorite.value > 2 {
            let percentage = Int((Double(favorite.value) / Double(totalDates)) * 100)
            return RelationshipInsight(
                icon: "🗺️",
                title: "Special Place Discovered",
                description: "You've returned to \(favorite.key) \(favorite.value) times (\(percentage)% of your dates). This location clearly holds special meaning—perhaps it's where you feel most comfortable being yourselves together."
            )
        } else if uniqueLocations >= 5 {
            return RelationshipInsight(
                icon: "🌍",
                title: "Adventure Seekers",
                description: "You've explored \(uniqueLocations) different locations together, showing your shared love for new experiences and adventure. This variety keeps your relationship fresh and exciting."
            )
        }
        
        return nil
    }
    
    private func analyzeTimePreferences(data: RelationshipAnalysisData) -> RelationshipInsight? {
        guard !data.timePatterns.isEmpty else { return nil }
        
        let averageHour = Double(data.timePatterns.reduce(0, +)) / Double(data.timePatterns.count)
        let eveningDates = data.timePatterns.filter { $0 >= 17 }.count
        let afternoonDates = data.timePatterns.filter { $0 >= 12 && $0 < 17 }.count
        let morningDates = data.timePatterns.filter { $0 < 12 }.count
        
        if eveningDates > afternoonDates && eveningDates > morningDates {
            return RelationshipInsight(
                icon: "🌆",
                title: "Evening Connection",
                description: "Most of your dates happen in the evening, creating intimate moments as the day winds down. This suggests you both value deep conversation and romantic ambiance."
            )
        } else if afternoonDates > morningDates && afternoonDates > eveningDates {
            return RelationshipInsight(
                icon: "☀️",
                title: "Afternoon Lovers",
                description: "You prefer afternoon dates, making the most of daylight hours together. This indicates an active, optimistic relationship filled with energy and shared activities."
            )
        } else if morningDates > 0 && morningDates >= afternoonDates {
            return RelationshipInsight(
                icon: "🌅",
                title: "Morning Partnership",
                description: "Your preference for morning dates is unique and special—starting days together shows deep commitment and the desire to share life's fresh beginnings."
            )
        }
        
        return nil
    }
    
    private func analyzeRelationshipMomentum(data: RelationshipAnalysisData) -> RelationshipInsight {
        let recentDates = data.dateIntervals.suffix(3)
        let overallAverage = Double(data.dateIntervals.reduce(0, +)) / Double(data.dateIntervals.count)
        
        if !recentDates.isEmpty {
            let recentAverage = Double(recentDates.reduce(0, +)) / Double(recentDates.count)
            
            if recentAverage < overallAverage * 0.7 {
                return RelationshipInsight(
                    icon: "🚀",
                    title: "Accelerating Bond",
                    description: "Your recent dating frequency has increased significantly, indicating growing excitement and deeper connection. The relationship momentum is building beautifully."
                )
            } else if recentAverage > overallAverage * 1.3 {
                return RelationshipInsight(
                    icon: "🌊",
                    title: "Natural Ebb",
                    description: "Recent dates are spaced slightly further apart, which is natural as relationships mature. This often indicates growing comfort and security with each other."
                )
            }
        }
        
        return RelationshipInsight(
            icon: "💝",
            title: "Steady Foundation",
            description: "Your dating pattern shows consistent commitment and reliability. This steady approach builds trust and demonstrates mutual respect for each other's time and feelings."
        )
    }
    
    private func analyzeMemories(data: RelationshipAnalysisData) -> RelationshipInsight? {
        guard !data.notes.isEmpty else { return nil }
        
        let totalNotes = data.notes.count
        let notePercentage = Int((Double(totalNotes) / Double(data.totalDates)) * 100)
        
        // Simple sentiment analysis based on keywords
        let positiveWords = ["amazing", "wonderful", "great", "love", "perfect", "beautiful", "fun", "happy", "best", "incredible"]
        let positiveCount = data.notes.reduce(0) { count, note in
            count + positiveWords.filter { note.lowercased().contains($0) }.count
        }
        
        if notePercentage >= 50 {
            return RelationshipInsight(
                icon: "📝",
                title: "Memory Keeper",
                description: "You've documented \(notePercentage)% of your dates with notes, showing how much these moments mean to you. Your attention to preserving memories demonstrates deep care for your relationship's story."
            )
        } else if positiveCount >= 3 {
            return RelationshipInsight(
                icon: "😊",
                title: "Joyful Memories",
                description: "Your notes are filled with positive emotions and happy memories. This emotional record shows a relationship built on joy, laughter, and genuine enjoyment of each other's company."
            )
        }
        
        return nil
    }
    
    private func analyzeEmotionalConnection(data: RelationshipAnalysisData) -> RelationshipInsight? {
        guard !data.emotionFrequency.isEmpty else { return nil }
        
        let sortedEmotions = data.emotionFrequency.sorted { $0.value > $1.value }
        let positiveEmotions = ["happy", "excited", "grateful", "loved", "peaceful", "content", "hopeful", "surprised"]
        let positiveCount = sortedEmotions.filter { positiveEmotions.contains($0.key.rawValue.lowercased()) }.count
        
        if let topEmotion = sortedEmotions.first {
            let topName = topEmotion.key.rawValue.lowercased()
            let intensity = Int(topEmotion.value)
            
            return RelationshipInsight(
                icon: "💕",
                title: "Emotional Signature",
                description: "Your most frequent emotion with \(data.personName) is \(topName) (intensity: \(intensity)/5). This emotional foundation shapes your connection—you feel genuinely good around each other. Out of \(data.emotionFrequency.count) emotions logged, \(positiveCount) are positive, reflecting a nurturing relationship."
            )
        }
        
        return nil
    }
    
    private func analyzeGiftExchange(data: RelationshipAnalysisData) -> RelationshipInsight? {
        let totalGifts = data.givenGifts + data.receivedGifts
        guard totalGifts > 0 else { return nil }
        
        if data.givenGifts > data.receivedGifts {
            return RelationshipInsight(
                icon: "🎁",
                title: "Generous Spirit",
                description: "You've given \(data.givenGifts) gifts while receiving \(data.receivedGifts). Your generosity demonstrates thoughtfulness and care—gift-giving is a beautiful love language you're using to show affection."
            )
        } else if data.receivedGifts > data.givenGifts {
            return RelationshipInsight(
                icon: "🎀",
                title: "Cherished & Appreciated",
                description: "You've received \(data.receivedGifts) gifts compared to giving \(data.givenGifts). Your partner shows their affection through thoughtful gestures, demonstrating how valued you are in their life."
            )
        } else if totalGifts > 0 {
            return RelationshipInsight(
                icon: "🎊",
                title: "Reciprocal Appreciation",
                description: "You and \(data.personName) have exchanged \(totalGifts) gifts equally. This balanced exchange shows mutual care and thoughtfulness—you both express love through meaningful presents."
            )
        }
        
        return nil
    }
    
    private func analyzePhysicalIntimacy(data: RelationshipAnalysisData) -> RelationshipInsight? {
        let totalTouchMoments = data.touchTypeFrequency.values.reduce(0, +)
        guard totalTouchMoments > 0 else { return nil }
        
        let avgTouchPerDate = Double(totalTouchMoments) / Double(max(1, data.totalDates))
        
        if let mostCommon = data.touchTypeFrequency.max(by: { $0.value < $1.value }) {
            let touchType = mostCommon.key.rawValue.lowercased()
            
            return RelationshipInsight(
                icon: "🤝",
                title: "Physical Connection",
                description: "You've shared \(totalTouchMoments) moments of physical intimacy across your dates. Your most common form is \(touchType), showing how you naturally express affection. With \(String(format: "%.1f", avgTouchPerDate)) moments per date, you maintain a healthy physical connection."
            )
        }
        
        return nil
    }
    
    private func analyzeDateTypePreferences(data: RelationshipAnalysisData) -> RelationshipInsight? {
        guard !data.dateTypeFrequency.isEmpty else { return nil }
        
        let sortedTypes = data.dateTypeFrequency.sorted { $0.value > $1.value }
        
        if let favorite = sortedTypes.first {
            let percentage = Int((Double(favorite.value) / Double(data.totalDates)) * 100)
            let typeName = favorite.key.rawValue.lowercased()
            
            return RelationshipInsight(
                icon: "🎯",
                title: "Date Type Preference",
                description: "\(percentage)% of your dates are \(typeName)s, showing this is your preferred way to spend time together. This consistency suggests you've found the activities that bring out the best in your connection."
            )
        }
        
        return nil
    }
    
    private func generatePersonalizedRecommendation(data: RelationshipAnalysisData) -> RelationshipInsight {
        // Generate recommendations based on patterns
        if data.monthsTogether < 3 && data.totalDates >= 5 {
            return RelationshipInsight(
                icon: "💡",
                title: "Next Chapter Suggestion",
                description: "Consider planning a slightly longer date experience—perhaps a weekend afternoon together. Your frequent early dates show strong connection; it's time to explore deeper shared experiences."
            )
        } else if data.locationFrequency.count <= 2 && data.totalDates >= 3 {
            return RelationshipInsight(
                icon: "🎯",
                title: "Exploration Opportunity",
                description: "Try exploring new locations together! You've established comfort in familiar places—now's the perfect time to create fresh memories in different environments."
            )
        } else if data.notes.count < data.totalDates / 2 {
            return RelationshipInsight(
                icon: "📱",
                title: "Memory Enhancement",
                description: "Consider adding more notes about your dates. These small details become precious memories over time and help you both reflect on your beautiful journey together."
            )
        } else {
            return RelationshipInsight(
                icon: "🌟",
                title: "Relationship Excellence",
                description: "Your dating patterns show exceptional thoughtfulness and care. Continue nurturing this beautiful connection—you're building something truly special together."
            )
        }
    }
    
    private func calculateConsistency(intervals: [Int]) -> Double {
        guard intervals.count > 1 else { return 1.0 }
        
        let average = Double(intervals.reduce(0, +)) / Double(intervals.count)
        let variance = intervals.reduce(0.0) { result, interval in
            result + pow(Double(interval) - average, 2)
        } / Double(intervals.count)
        
        let standardDeviation = sqrt(variance)
        let coefficient = standardDeviation / average
        
        return max(0.0, 1.0 - coefficient)
    }
}

struct RelationshipAnalysisData {
    let personName: String
    let daysTogether: Int
    let monthsTogether: Int
    let totalDates: Int
    let dateIntervals: [Int]
    let locationFrequency: [String: Int]
    let notes: [String]
    let timePatterns: [Int]
    let phoneNumber: String
    let emotionFrequency: [EmotionType: Double]
    let givenGifts: Int
    let receivedGifts: Int
    let touchTypeFrequency: [PhysicalTouchType: Int]
    let discussionPoints: [String]
    let journalEntries: [String]
    let dateTypeFrequency: [DateType: Int]
}