//
//  OnboardingSteps.swift
//  Heartbeat
//
//  Created by Liam Arbuckle on 8/1/2026.
//

import SwiftUI
import PhotosUI


struct NameInputStep: View {
    @Binding var name: String
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 24) {
            Text("What's their name?")
                .font(AppStyle.Fonts.title)
                .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                .multilineTextAlignment(.center)
            
            TextField("Enter name", text: $name)
                .textFieldStyle(CustomTextFieldStyle())
                .textInputAutocapitalization(.words)
                .submitLabel(.next)
        }
    }
}

struct PhoneInputStep: View {
    @Binding var phoneNumber: String
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Phone number?")
                .font(AppStyle.Fonts.title)
                .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                .multilineTextAlignment(.center)
            
            Text("Optional - so you can call them after an amazing date!")
                .font(AppStyle.Fonts.body)
                .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                .multilineTextAlignment(.center)
            
            TextField("Enter phone number", text: $phoneNumber)
                .textFieldStyle(CustomTextFieldStyle())
                .keyboardType(.phonePad)
        }
    }
}

struct PhotoInputStep: View {
    @Binding var selectedPhoto: PhotosPickerItem?
    @Binding var photoData: Data?
    @Binding var showingPhotoCropper: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Add a photo?")
                .font(AppStyle.Fonts.title)
                .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                .multilineTextAlignment(.center)
            
            Text("Optional - but it makes everything more personal!")
                .font(AppStyle.Fonts.body)
                .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                .multilineTextAlignment(.center)
            
            PhotosPickerButton(
                selectedPhoto: $selectedPhoto,
                photoData: $photoData
            )
        }
    }
}

struct MeetingDateStep: View {
    @Binding var meetingDate: Date
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 24) {
            Text("When did you first meet?")
                .font(AppStyle.Fonts.title)
                .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                .multilineTextAlignment(.center)
            
            DatePicker(
                "Meeting Date",
                selection: $meetingDate,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .accentColor(AppStyle.Colors.accent)
        }
    }
}

struct PreviousDatesStep: View {
    @Binding var hasPreviousDates: Bool
    @Binding var previousDates: [PreviousDateInput]
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Any previous dates to add?")
                .font(AppStyle.Fonts.title)
                .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                .multilineTextAlignment(.center)
            
            Toggle("I have previous dates to add", isOn: $hasPreviousDates)
                .toggleStyle(SwitchToggleStyle(tint: AppStyle.Colors.accent))
            
            if hasPreviousDates {
                GeometryReader { geometry in
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(previousDates.indices, id: \.self) { index in
                                PreviousDateCard(
                                    dateInput: $previousDates[index],
                                    onRemove: {
                                        previousDates.remove(at: index)
                                        if previousDates.isEmpty {
                                            hasPreviousDates = false
                                        }
                                    }
                                )
                            }
                            Button("ADD DATE") {
                                previousDates.append(PreviousDateInput())
                            }
                            .buttonStyle(SecondaryButtonStyle())
                        }
                        .frame(minHeight: geometry.size.height)
                    }
                }
            }
        }
        .onChange(of: hasPreviousDates) { _, newValue in
            if newValue && previousDates.isEmpty {
                previousDates.append(PreviousDateInput())
            }
        }
    }
}

struct PhotosPickerButton: View {
    @Binding var selectedPhoto: PhotosPickerItem?
    @Binding var photoData: Data?
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        PhotosPicker(
            selection: $selectedPhoto,
            matching: .images,
            photoLibrary: .shared()
        ) {
            ZStack {
                Rectangle()
                    .fill(AppStyle.Colors.surface(for: colorScheme))
                    .frame(width: 150, height: 150)
                    .overlay {
                        Rectangle()
                            .stroke(AppStyle.Colors.borderColor, lineWidth: AppStyle.Layout.borderWidth)
                    }
                
                if let photoData = photoData, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 150)
                        .clipped()
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 30))
                            .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                        
                        Text("TAP TO ADD PHOTO")
                            .font(AppStyle.Fonts.caption)
                            .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                    }
                }
            }
            .shadow(
                color: AppStyle.Colors.shadowColor,
                radius: 0,
                x: AppStyle.Layout.shadowOffset.width,
                y: AppStyle.Layout.shadowOffset.height
            )
        }
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    photoData = data
                }
            }
        }
    }
}

struct PreviousDateCard: View {
    @Binding var dateInput: PreviousDateInput
    let onRemove: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingLocationSearch = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Spacer()
                Button("REMOVE") {
                    onRemove()
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            
            Button(action: {
                showingLocationSearch = true
            }) {
                HStack {
                    Text(dateInput.location.isEmpty ? "TAP TO SEARCH LOCATION" : dateInput.location.uppercased())
                        .font(AppStyle.Fonts.body)
                        .foregroundColor(dateInput.location.isEmpty ? AppStyle.Colors.textSecondary(for: colorScheme) : AppStyle.Colors.textPrimary(for: colorScheme))
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
            .sheet(isPresented: $showingLocationSearch) {
                LocationSearchView(
                    selectedLocation: Binding(
                        get: { dateInput.location },
                        set: { dateInput.location = $0 }
                    ),
                    selectedLatitude: Binding(
                        get: { dateInput.latitude == 0 ? nil : dateInput.latitude },
                        set: { dateInput.latitude = $0 ?? 0 }
                    ),
                    selectedLongitude: Binding(
                        get: { dateInput.longitude == 0 ? nil : dateInput.longitude },
                        set: { dateInput.longitude = $0 ?? 0 }
                    ),
                    isPresented: $showingLocationSearch
                )
            }
            
            DatePicker("Date", selection: $dateInput.date, displayedComponents: .date)
                .datePickerStyle(.compact)
            
            DatePicker("Time", selection: $dateInput.time, displayedComponents: .hourAndMinute)
                .datePickerStyle(.compact)
            
            TextField("Notes (optional)", text: $dateInput.notes, axis: .vertical)
                .textFieldStyle(CustomTextFieldStyle())
                .lineLimit(3...6)
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
            x: AppStyle.Layout.shadowOffset.width,
            y: AppStyle.Layout.shadowOffset.height
        )
    }
}

struct PreviousDateInput: Identifiable {
    let id = UUID()
    var location: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
    var date: Date = Date()
    var time: Date = Date()
    var notes: String = ""
}
