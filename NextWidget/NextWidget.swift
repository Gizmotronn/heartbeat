//
//  NextWidget.swift
//  NextWidget
//
//  Created by Liam Arbuckle on 9/1/2026.
//

import WidgetKit
import SwiftUI
import MapKit

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
    
    static func loadFromSharedContainer() -> WidgetData {
        let appGroupIdentifier = "group.com.heartbeat.app"
        let widgetDataFilename = "nextDateWidgetData.json"
        
        // Write debug log to shared container
        func writeDebugLog(_ message: String) {
            guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else { return }
            let logURL = containerURL.appendingPathComponent("widget_debug.log")
            let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
            let logMessage = "[\(timestamp)] \(message)\n"
            
            if let data = logMessage.data(using: .utf8) {
                if FileManager.default.fileExists(atPath: logURL.path) {
                    if let handle = try? FileHandle(forWritingTo: logURL) {
                        handle.seekToEndOfFile()
                        handle.write(data)
                        handle.closeFile()
                    }
                } else {
                    try? data.write(to: logURL)
                }
            }
        }
        
        writeDebugLog("Widget loadFromSharedContainer called")
        
        // Get shared container
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            writeDebugLog("FAILED to get container URL!")
            return WidgetData(
                personName: "No Container",
                upcomingDate: Date().addingTimeInterval(86400),
                location: "App group error",
                displayText: "Error",
                hasData: false
            )
        }
        
        writeDebugLog("Container URL: \(containerURL.path)")
        
        let fileURL = containerURL.appendingPathComponent(widgetDataFilename)
        let fileExists = FileManager.default.fileExists(atPath: fileURL.path)
        writeDebugLog("File exists at \(fileURL.lastPathComponent): \(fileExists)")
        
        // List container contents
        if let contents = try? FileManager.default.contentsOfDirectory(atPath: containerURL.path) {
            writeDebugLog("Container contents: \(contents.joined(separator: ", "))")
        }
        
        // Try to read file
        if let data = try? Data(contentsOf: fileURL) {
            writeDebugLog("Read \(data.count) bytes from file")
            if let decoded = try? JSONDecoder().decode(WidgetData.self, from: data) {
                writeDebugLog("Decoded successfully: \(decoded.personName) at \(decoded.location)")
                writeDebugLog("hasData value: \(decoded.hasData)")
                writeDebugLog("upcomingDate: \(decoded.upcomingDate)")
                writeDebugLog("Current date: \(Date())")
                return decoded
            } else {
                writeDebugLog("Failed to decode JSON")
                // Try to see the raw JSON
                if let jsonString = String(data: data.prefix(500), encoding: .utf8) {
                    writeDebugLog("Raw JSON start: \(jsonString)")
                }
            }
        } else {
            writeDebugLog("Failed to read file data")
        }
        
        // Fallback to UserDefaults
        writeDebugLog("Trying UserDefaults fallback...")
        if let userDefaults = UserDefaults(suiteName: appGroupIdentifier),
           let data = userDefaults.data(forKey: "nextDateWidgetData") {
            writeDebugLog("Found UserDefaults data: \(data.count) bytes")
            if let decoded = try? JSONDecoder().decode(WidgetData.self, from: data) {
                writeDebugLog("UserDefaults decode success: \(decoded.personName)")
                return decoded
            }
        } else {
            writeDebugLog("No UserDefaults data found")
        }
        
        writeDebugLog("Returning empty widget data")
        return WidgetData(
            personName: "No Data",
            upcomingDate: Date().addingTimeInterval(86400),
            location: "Open Heartbeat app",
            displayText: "Add a date",
            hasData: false
        )
    }
}

struct CountdownEntry: TimelineEntry {
    let date: Date
    let widgetData: WidgetData
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> CountdownEntry {
        CountdownEntry(date: Date(), widgetData: WidgetData.loadFromSharedContainer())
    }

    func getSnapshot(in context: Context, completion: @escaping (CountdownEntry) -> ()) {
        completion(CountdownEntry(date: Date(), widgetData: WidgetData.loadFromSharedContainer()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let widgetData = WidgetData.loadFromSharedContainer()
        let currentDate = Date()
        
        // Create timeline entries
        var entries: [CountdownEntry] = []
        for minuteOffset in stride(from: 0, to: 60, by: 5) {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            entries.append(CountdownEntry(date: entryDate, widgetData: widgetData))
        }
        
        // Refresh every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        completion(Timeline(entries: entries, policy: .after(nextUpdate)))
    }
}

struct NextWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) private var widgetFamily
    
    private var timeRemaining: (days: Int, hours: Int, minutes: Int) {
        let interval = entry.widgetData.upcomingDate.timeIntervalSince(entry.date)
        guard interval > 0 else { return (0, 0, 0) }
        
        let days = Int(interval) / 86400
        let hours = (Int(interval) % 86400) / 3600
        let minutes = (Int(interval) % 3600) / 60
        return (days, hours, minutes)
    }
    
    private var isPast: Bool {
        entry.widgetData.upcomingDate <= entry.date
    }

    var body: some View {
        Group {
            if widgetFamily == .systemSmall {
                smallWidgetView
            } else {
                mediumWidgetView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
    
    @ViewBuilder
    private var smallWidgetView: some View {
        VStack(spacing: 4) {
            Text(entry.widgetData.personName.uppercased())
                .font(.system(size: 12, weight: .black))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text("\(timeRemaining.days)D \(timeRemaining.hours)H")
                .font(.system(size: 16, weight: .black))
                .foregroundColor(.pink)
            
            Text(entry.widgetData.location.uppercased())
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
    }
    
    @ViewBuilder
    private var mediumWidgetView: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.pink.opacity(0.1),
                    Color.purple.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(entry.widgetData.personName.uppercased())
                        .font(.system(size: 14, weight: .black))
                        .lineLimit(1)
                    
                    Text("\(timeRemaining.days)D \(timeRemaining.hours)H \(timeRemaining.minutes)M")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(.pink)
                    
                    Text(entry.widgetData.location.uppercased())
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                    
                personPhotoView
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black, lineWidth: 2))
            }
            .padding(12)
        }
    }
    
    @ViewBuilder
    private var countdownView: some View {
        let time = timeRemaining
        VStack(spacing: 2) {
            if time.days > 0 {
                Text("\(time.days)D \(time.hours)H")
                    .font(.system(size: widgetFamily == .systemSmall ? 16 : 18, weight: .black))
                    .foregroundColor(.pink)
            } else if time.hours > 0 {
                Text("\(time.hours)H \(time.minutes)M")
                    .font(.system(size: widgetFamily == .systemSmall ? 16 : 18, weight: .black))
                    .foregroundColor(.pink)
            } else {
                Text("\(max(time.minutes, 1))M")
                    .font(.system(size: widgetFamily == .systemSmall ? 18 : 20, weight: .black))
                    .foregroundColor(.pink)
            }
            
            Text("TO GO")
                .font(.system(size: widgetFamily == .systemSmall ? 8 : 10, weight: .bold))
        }
    }
    
    @ViewBuilder
    private var personPhotoView: some View {
        if let photoData = entry.widgetData.personPhotoData,
           let uiImage = UIImage(data: photoData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            ZStack {
                Circle().fill(Color.pink)
                Text(String(entry.widgetData.personName.prefix(1).uppercased()))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
    
    @ViewBuilder
    private var locationMapView: some View {
        if let lat = entry.widgetData.latitude, let lon = entry.widgetData.longitude {
            MapSnapshotView(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
        } else {
            ZStack {
                Color.gray.opacity(0.2)
                Image(systemName: "map")
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
            }
        }
    }
}

struct MapSnapshotView: View {
    let coordinate: CLLocationCoordinate2D
    @State private var snapshotImage: UIImage?
    
    var body: some View {
        Group {
            if let image = snapshotImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                ZStack {
                    Color.gray.opacity(0.2)
                    Image(systemName: "map")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                }
                .onAppear { generateSnapshot() }
            }
        }
    }
    
    private func generateSnapshot() {
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        options.size = CGSize(width: 160, height: 160)
        options.scale = 2.0
        
        MKMapSnapshotter(options: options).start { snapshot, error in
            if let snapshot = snapshot {
                snapshotImage = snapshot.image
            }
        }
    }
}

struct NextWidget: Widget {
    let kind: String = "NextWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                NextWidgetEntryView(entry: entry)
                    .containerBackground(.clear, for: .widget)
            } else {
                NextWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("Next Date")
        .description("Countdown to your next date night.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    NextWidget()
} timeline: {
    CountdownEntry(date: Date(), widgetData: WidgetData(
        personName: "Alex",
        upcomingDate: Date().addingTimeInterval(86400 * 3),
        location: "Fancy Restaurant",
        displayText: "3 days",
        hasData: true
    ))
}

#Preview(as: .systemMedium) {
    NextWidget()
} timeline: {
    CountdownEntry(date: Date(), widgetData: WidgetData(
        personName: "Alex",
        upcomingDate: Date().addingTimeInterval(86400 * 3),
        location: "Fancy Restaurant",
        displayText: "3 days",
        hasData: true,
        latitude: 40.7128,
        longitude: -74.0060
    ))
}

