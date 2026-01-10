//
//  Item.swift
//  Heartbeat
//
//  Created by Liam Arbuckle on 8/1/2026.
//

import Foundation
import SwiftData
import SwiftUI
import MapKit
import CoreLocation

// MARK: - Emotion System (Apple Journal style)
enum EmotionType: String, Codable, CaseIterable {
    case happy = "Happy"
    case excited = "Excited"
    case grateful = "Grateful"
    case loved = "Loved"
    case peaceful = "Peaceful"
    case content = "Content"
    case hopeful = "Hopeful"
    case surprised = "Surprised"
    case sad = "Sad"
    case anxious = "Anxious"
    case frustrated = "Frustrated"
    case disappointed = "Disappointed"
    case angry = "Angry"
    case worried = "Worried"
    case lonely = "Lonely"
    case overwhelmed = "Overwhelmed"
    
    var color: Color {
        switch self {
        // Positive emotions - warm/bright colors
        case .happy:
            return Color(red: 1.0, green: 0.8, blue: 0.2) // Bright yellow
        case .excited:
            return Color(red: 1.0, green: 0.4, blue: 0.0) // Orange
        case .grateful:
            return Color(red: 0.9, green: 0.6, blue: 0.8) // Light pink
        case .loved:
            return Color(red: 1.0, green: 0.2, blue: 0.4) // Rose
        case .peaceful:
            return Color(red: 0.4, green: 0.7, blue: 0.9) // Light blue
        case .content:
            return Color(red: 0.6, green: 0.8, blue: 0.4) // Light green
        case .hopeful:
            return Color(red: 0.5, green: 0.9, blue: 0.7) // Mint green
        case .surprised:
            return Color(red: 0.8, green: 0.4, blue: 0.9) // Light purple
        // Negative emotions - cooler/darker colors
        case .sad:
            return Color(red: 0.4, green: 0.5, blue: 0.7) // Muted blue
        case .anxious:
            return Color(red: 0.7, green: 0.5, blue: 0.3) // Muted orange
        case .frustrated:
            return Color(red: 0.8, green: 0.3, blue: 0.3) // Muted red
        case .disappointed:
            return Color(red: 0.6, green: 0.6, blue: 0.7) // Gray blue
        case .angry:
            return Color(red: 0.9, green: 0.2, blue: 0.2) // Red
        case .worried:
            return Color(red: 0.7, green: 0.6, blue: 0.4) // Muted brown
        case .lonely:
            return Color(red: 0.5, green: 0.5, blue: 0.6) // Cool gray
        case .overwhelmed:
            return Color(red: 0.6, green: 0.4, blue: 0.6) // Muted purple
        }
    }
    
    var systemImage: String {
        switch self {
        case .happy: return "face.smiling"
        case .excited: return "star.circle"
        case .grateful: return "heart.circle"
        case .loved: return "heart.fill"
        case .peaceful: return "leaf.circle"
        case .content: return "checkmark.circle"
        case .hopeful: return "sunrise.circle"
        case .surprised: return "exclamationmark.circle"
        case .sad: return "face.dashed"
        case .anxious: return "waveform.circle"
        case .frustrated: return "exclamationmark.triangle"
        case .disappointed: return "hand.thumbsdown.circle"
        case .angry: return "flame.circle"
        case .worried: return "cloud.circle"
        case .lonely: return "person.circle"
        case .overwhelmed: return "tornado.circle"
        }
    }
}

@Model
final class EmotionEntry {
    var emotionTypeRaw: String
    var intensity: Int // 1-5 scale
    var timestamp: Date
    
    init(emotionType: EmotionType, intensity: Int = 3, timestamp: Date = Date()) {
        self.emotionTypeRaw = emotionType.rawValue
        self.intensity = max(1, min(5, intensity))
        self.timestamp = timestamp
    }
    
    var emotionType: EmotionType {
        get { EmotionType(rawValue: emotionTypeRaw) ?? .happy }
        set { emotionTypeRaw = newValue.rawValue }
    }
}

@Model
final class Gift {
    var item: String
    var giver: String // "me" or "them"
    var giftDescription: String
    var timestamp: Date
    
    init(item: String, giver: String, description: String = "", timestamp: Date = Date()) {
        self.item = item
        self.giver = giver
        self.giftDescription = description
        self.timestamp = timestamp
    }
    
    var description: String {
        get { giftDescription }
        set { giftDescription = newValue }
    }
}

enum PhysicalTouchType: String, Codable, CaseIterable {
    case hug = "Hug"
    case kiss = "Kiss"
    case handHolding = "Hand Holding"
    case cuddle = "Cuddle"
    case highFive = "High Five"
    case pat = "Pat"
    case massage = "Massage"
    case other = "Other"
    
    var systemImage: String {
        switch self {
        case .hug: return "figure.2.arms.open"
        case .kiss: return "heart.circle"
        case .handHolding: return "hands.clap"
        case .cuddle: return "figure.2.and.child.holdinghands"
        case .highFive: return "hand.raised"
        case .pat: return "hand.point.right"
        case .massage: return "hands.sparkles"
        case .other: return "hand.point.up"
        }
    }
}

@Model
final class PhysicalTouchMoment {
    var touchTypeRaw: String
    var duration: String // "brief", "medium", "long"
    var context: String
    var timestamp: Date
    
    init(touchType: PhysicalTouchType, duration: String = "medium", context: String = "", timestamp: Date = Date()) {
        self.touchTypeRaw = touchType.rawValue
        self.duration = duration
        self.context = context
        self.timestamp = timestamp
    }
    
    var touchType: PhysicalTouchType {
        get { PhysicalTouchType(rawValue: touchTypeRaw) ?? .hug }
        set { touchTypeRaw = newValue.rawValue }
    }
}

enum DateType: String, Codable, CaseIterable {
    case coffee = "Coffee"
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case museumGallery = "Museum/Gallery"
    case walk = "Walk"
    case dogWalk = "Dog Walk"
    case dinnerTheirs = "Dinner (at theirs)"
    
    var accentColor: Color {
        switch self {
        case .coffee:
            return Color(red: 0.8, green: 0.6, blue: 0.4)
        case .breakfast:
            return Color(red: 1.0, green: 0.8, blue: 0.2)
        case .lunch:
            return Color(red: 0.4, green: 0.8, blue: 0.4)
        case .dinner:
            return Color(red: 0.8, green: 0.2, blue: 0.2)
        case .museumGallery:
            return Color(red: 0.6, green: 0.2, blue: 0.8)
        case .walk:
            return Color(red: 0.2, green: 0.8, blue: 0.8)
        case .dogWalk:
            return Color(red: 0.8, green: 0.6, blue: 0.2)
        case .dinnerTheirs:
            return Color(red: 0.8, green: 0.4, blue: 0.6)
        }
    }
    
    var displayName: String {
        self.rawValue
    }
}

@Model
final class DatePerson {
    var name: String
    var phoneNumber: String
    var photoData: Data?
    var meetingDate: Date
    var previousDates: [PreviousDate]
    var createdAt: Date
    
    init(name: String, phoneNumber: String = "", photoData: Data? = nil, meetingDate: Date, previousDates: [PreviousDate] = []) {
        self.name = name
        self.phoneNumber = phoneNumber
        self.photoData = photoData
        self.meetingDate = meetingDate
        self.previousDates = previousDates
        self.createdAt = Date()
    }
    
    var profileImage: Image? {
        guard let photoData = photoData,
              let uiImage = UIImage(data: photoData) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }
}

@Model
final class PreviousDate {
    var location: String
    var latitude: Double?
    var longitude: Double?
    var date: Date
    var time: Date
    var notes: String
    var dateType: DateType?
    var person: DatePerson?
    
    // New detailed fields for past dates
    var discussionPoints: [String]
    var emotions: [EmotionEntry]
    var journalEntry: String
    var gifts: [Gift]
    var physicalTouchMoments: [PhysicalTouchMoment]
    
    init(location: String, latitude: Double? = nil, longitude: Double? = nil, date: Date, time: Date, notes: String = "", dateType: DateType = .dinner, discussionPoints: [String] = [], emotions: [EmotionEntry] = [], journalEntry: String = "", gifts: [Gift] = [], physicalTouchMoments: [PhysicalTouchMoment] = []) {
        self.location = location
        self.latitude = latitude
        self.longitude = longitude
        self.date = date
        self.time = time
        self.notes = notes
        self.dateType = dateType
        self.discussionPoints = discussionPoints
        self.emotions = emotions
        self.journalEntry = journalEntry
        self.gifts = gifts
        self.physicalTouchMoments = physicalTouchMoments
    }
    
    var effectiveDateType: DateType {
        dateType ?? .dinner
    }
    
    // Helper to check if this date can be opened in Apple Maps
    var canOpenInMaps: Bool {
        return !location.isEmpty && latitude != nil && longitude != nil
    }
    
    // Helper to open in Apple Maps
    func openInAppleMaps() {
        guard let lat = latitude, let lon = longitude, !location.isEmpty else { return }
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = location
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    // Combined date and time for display
    var fullDateTime: Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        var combined = DateComponents()
        combined.year = dateComponents.year
        combined.month = dateComponents.month
        combined.day = dateComponents.day
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute
        
        return calendar.date(from: combined) ?? date
    }
}

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
