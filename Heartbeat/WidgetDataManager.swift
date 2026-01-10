//
//  WidgetDataManager.swift
//  Heartbeat
//
//  Created by Liam Arbuckle on 9/1/2026.
//

import Foundation
import SwiftData
import WidgetKit
import UIKit

// Data model for widget data shared with widget extension
struct WidgetData: Codable {
    let personName: String
    let upcomingDate: Date
    let location: String
    let displayText: String
    let hasData: Bool
    let personPhotoData: Data?
    let latitude: Double?
    let longitude: Double?
    
    init(personName: String, upcomingDate: Date, location: String, displayText: String, hasData: Bool = true, personPhotoData: Data? = nil, latitude: Double? = nil, longitude: Double? = nil) {
        self.personName = personName
        self.upcomingDate = upcomingDate
        self.location = location
        self.displayText = displayText
        self.hasData = hasData
        self.personPhotoData = personPhotoData
        self.latitude = latitude
        self.longitude = longitude
    }
    
    // Custom decoder to handle backwards compatibility
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        personName = try container.decode(String.self, forKey: .personName)
        upcomingDate = try container.decode(Date.self, forKey: .upcomingDate)
        location = try container.decode(String.self, forKey: .location)
        displayText = try container.decode(String.self, forKey: .displayText)
        hasData = try container.decodeIfPresent(Bool.self, forKey: .hasData) ?? true
        personPhotoData = try container.decodeIfPresent(Data.self, forKey: .personPhotoData)
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
    }
    
    private enum CodingKeys: String, CodingKey {
        case personName, upcomingDate, location, displayText, hasData, personPhotoData, latitude, longitude
    }
}

struct WidgetDataManager {
    private static let appGroupIdentifier = "group.com.heartbeat.app"
    private static let widgetDataFilename = "nextDateWidgetData.json"
    
    private static var sharedContainerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)
    }
    
    private static var widgetDataFileURL: URL? {
        sharedContainerURL?.appendingPathComponent(widgetDataFilename)
    }
    
    static func updateWidgetData(from people: [DatePerson]) {
        print("WidgetDataManager: Device info - \(UIDevice.current.name), iOS \(UIDevice.current.systemVersion)")
        print("WidgetDataManager: Bundle ID - \(Bundle.main.bundleIdentifier ?? "unknown")")
        
        guard let containerURL = sharedContainerURL else {
            print("WidgetDataManager: ERROR - Could not get shared container URL for \(appGroupIdentifier)!")
            print("WidgetDataManager: This usually means the app group entitlement is not properly configured")
            return
        }
        
        let fileURL = containerURL.appendingPathComponent(widgetDataFilename)
        print("WidgetDataManager: Container URL: \(containerURL.path)")
        print("WidgetDataManager: Using file URL: \(fileURL.path)")
        
        // Ensure container directory exists
        do {
            try FileManager.default.createDirectory(at: containerURL, withIntermediateDirectories: true, attributes: nil)
            print("WidgetDataManager: Container directory created/verified")
        } catch {
            print("WidgetDataManager: Failed to create container directory: \(error)")
        }
        
        guard !people.isEmpty else {
            // Clear widget data if no people
            try? FileManager.default.removeItem(at: fileURL)
            WidgetCenter.shared.reloadAllTimelines()
            return
        }
        
        // Find the next upcoming date across all people
        let allUpcomingDates = people.flatMap { person in
            person.previousDates.compactMap { date -> (person: DatePerson, date: PreviousDate)? in
                // Only include future dates
                if date.fullDateTime > Date() {
                    return (person: person, date: date)
                }
                return nil
            }
        }.sorted { $0.date.fullDateTime < $1.date.fullDateTime }
        
        guard let nextDate = allUpcomingDates.first else {
            // No upcoming dates found
            try? FileManager.default.removeItem(at: fileURL)
            WidgetCenter.shared.reloadAllTimelines()
            print("WidgetDataManager: No upcoming dates found")
            return
        }
        
        // Compress photo for widget - max 100x100 pixels, JPEG quality 0.5
        var compressedPhotoData: Data? = nil
        if let originalData = nextDate.person.photoData,
           let originalImage = UIImage(data: originalData) {
            let maxSize: CGFloat = 100
            let scale = min(maxSize / originalImage.size.width, maxSize / originalImage.size.height, 1.0)
            let newSize = CGSize(width: originalImage.size.width * scale, height: originalImage.size.height * scale)
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            originalImage.draw(in: CGRect(origin: .zero, size: newSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            compressedPhotoData = resizedImage?.jpegData(compressionQuality: 0.5)
            print("WidgetDataManager: Compressed photo from \(originalData.count) to \(compressedPhotoData?.count ?? 0) bytes")
        }
        
        let widgetData = WidgetData(
            personName: nextDate.person.name,
            upcomingDate: nextDate.date.fullDateTime,
            location: nextDate.date.location,
            displayText: formatDisplayText(person: nextDate.person, date: nextDate.date),
            hasData: true,
            personPhotoData: compressedPhotoData,
            latitude: nextDate.date.latitude,
            longitude: nextDate.date.longitude
        )
        
        do {
            let encodedData = try JSONEncoder().encode(widgetData)
            try encodedData.write(to: fileURL)
            print("WidgetDataManager: Successfully wrote widget data to \(fileURL.path)")
            
            // Also write to UserDefaults as backup for device compatibility
            if let userDefaults = UserDefaults(suiteName: appGroupIdentifier) {
                userDefaults.set(encodedData, forKey: "nextDateWidgetData")
                userDefaults.synchronize()
                print("WidgetDataManager: Also wrote to UserDefaults as backup")
            }
            
            WidgetCenter.shared.reloadAllTimelines()
            print("WidgetDataManager: Updated widget data for \(nextDate.person.name) at \(nextDate.date.location) on \(nextDate.date.fullDateTime)")
            print("WidgetDataManager: Triggered widget timeline reload")
            
            // Read widget debug log if it exists
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if let logURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)?.appendingPathComponent("widget_debug.log"),
                   let logContent = try? String(contentsOf: logURL, encoding: .utf8) {
                    print("=== WIDGET DEBUG LOG ===")
                    print(logContent)
                    print("========================")
                }
            }
        } catch {
            print("WidgetDataManager: Failed to write widget data to file: \(error)")
            
            // Try UserDefaults fallback
            if let userDefaults = UserDefaults(suiteName: appGroupIdentifier),
               let encodedData = try? JSONEncoder().encode(widgetData) {
                userDefaults.set(encodedData, forKey: "nextDateWidgetData")
                userDefaults.synchronize()
                WidgetCenter.shared.reloadAllTimelines()
                print("WidgetDataManager: Fallback to UserDefaults successful")
            } else {
                print("WidgetDataManager: All methods failed to save widget data")
            }
        }
    }
    
    private static func formatDisplayText(person: DatePerson, date: PreviousDate) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return "\(person.name) - \(formatter.string(from: date.fullDateTime))"
    }
    
    static func clearWidgetData() {
        guard let fileURL = widgetDataFileURL else {
            print("WidgetDataManager: ERROR - Could not get shared container URL!")
            return
        }
        try? FileManager.default.removeItem(at: fileURL)
        WidgetCenter.shared.reloadAllTimelines()
        print("WidgetDataManager: Cleared widget data")
    }
}