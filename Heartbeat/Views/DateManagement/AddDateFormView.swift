//
//  AddDateFormView.swift
//  Heartbeat
//
//  Created by Liam Arbuckle on 8/1/2026.
//

import SwiftUI
import MapKit

struct AddDateFormView: View {
    @Binding var location: String
    @Binding var latitude: Double?
    @Binding var longitude: Double?
    @Binding var date: Date
    @Binding var time: Date
    @Binding var notes: String
    @Binding var dateType: DateType
    @Binding var showingLocationSearch: Bool
    var isEditing: Bool = false
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 32) {
            ZStack {
                Color.clear
                LocationSearchButton(
                    location: $location,
                    latitude: $latitude,
                    longitude: $longitude,
                    showingLocationSearch: $showingLocationSearch
                )
            }
            .frame(width: 420, height: 90)
            .padding(.horizontal)

            ZStack {
                Color.clear
                DateTimePickerView(date: $date, time: $time)
            }
            .frame(width: 420, height: 90)
            .padding(.horizontal)

            ZStack {
                Color.clear
                DateTypePickerView(dateType: $dateType, isEditing: isEditing)
            }
            .frame(width: 420, height: 90)
            .padding(.horizontal)

            if combinedDateTime <= Date() {
                NotesInputView(notes: $notes)
                    .frame(width: 420)
                    .padding(.horizontal)
            }
        }
    }
    
    private var combinedDateTime: Date {
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

struct LocationSearchButton: View {
    @Binding var location: String
    @Binding var latitude: Double?
    @Binding var longitude: Double?
    @Binding var showingLocationSearch: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            // Search button
            Button(action: {
                showingLocationSearch = true
            }) {
                HStack {
                    Text(location.isEmpty ? "TAP TO SEARCH LOCATION" : location.uppercased())
                        .font(AppStyle.Fonts.body)
                        .foregroundColor(location.isEmpty ? AppStyle.Colors.textSecondary(for: colorScheme) : AppStyle.Colors.textPrimary(for: colorScheme))
                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppStyle.Colors.accent)
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
                    x: 3,
                    y: 3
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Apple Maps link (show only if location is selected)
            if !location.isEmpty, let lat = latitude, let lon = longitude {
                Button(action: {
                    openInAppleMaps(latitude: lat, longitude: lon, name: location)
                }) {
                    HStack {
                        Image(systemName: "map.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Text("OPEN IN APPLE MAPS")
                            .font(AppStyle.Fonts.caption)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppStyle.Colors.accent)
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
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private func openInAppleMaps(latitude: Double, longitude: Double, name: String) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}

struct DateTimePickerView: View {
    @Binding var date: Date
    @Binding var time: Date
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            Text("DATE & TIME")
                .font(AppStyle.Fonts.body)
                .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
            
            HStack(spacing: 12) {
                DatePicker("Date", selection: $date, displayedComponents: [.date])
                    .labelsHidden()
                    .accentColor(AppStyle.Colors.accent)
                
                DatePicker("Time", selection: $time, displayedComponents: [.hourAndMinute])
                    .labelsHidden()
                    .accentColor(AppStyle.Colors.accent)
            }
        }
        .neobrutalistCard()
    }
}

struct DateTypePickerView: View {
    @Binding var dateType: DateType
    var isEditing: Bool = false
    @State private var showAllOptions = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 16) {
            Text("DATE TYPE")
                .font(AppStyle.Fonts.body)
                .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))

            if isEditing && !showAllOptions {
                HStack(spacing: 12) {
                    Text(dateType.displayName)
                        .font(AppStyle.Fonts.body)
                        .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                        .frame(minWidth: 100, minHeight: 48)
                        .background(dateType.accentColor.opacity(0.2))
                        .cornerRadius(8)
                    Button("Change type") {
                        showAllOptions = true
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .frame(minWidth: 100, minHeight: 48)
                }
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                    ForEach(DateType.allCases, id: \.self) { type in
                        Button(action: {
                            dateType = type
                            if isEditing { showAllOptions = false }
                        }) {
                            VStack(spacing: 8) {
                                Text(type.displayName)
                                    .font(AppStyle.Fonts.caption)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(minWidth: 100, minHeight: 48)
                            .background(dateType == type ? type.accentColor.opacity(0.2) : AppStyle.Colors.surface(for: colorScheme))
                            .overlay {
                                Rectangle()
                                    .stroke(dateType == type ? type.accentColor : AppStyle.Colors.borderColor, lineWidth: dateType == type ? 2 : AppStyle.Layout.borderWidth)
                            }
                        }
                        .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                    }
                }
            }
        }
        .neobrutalistCard()
    }
}

struct NotesInputView: View {
    @Binding var notes: String
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            Text("NOTES (OPTIONAL)")
                .font(AppStyle.Fonts.body)
                .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
            
            TextField("HOW WAS THE DATE?", text: $notes, axis: .vertical)
                .textFieldStyle(CustomTextFieldStyle())
                .lineLimit(3...6)
        }
    }
}
