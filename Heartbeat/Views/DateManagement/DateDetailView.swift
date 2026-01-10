//
//  DateDetailView.swift
//  Heartbeat
//
//  Created by Liam Arbuckle on 8/1/2026.
//

import SwiftUI
import SwiftData

struct DateDetailView: View {
    let person: DatePerson
    let date: PreviousDate
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    
    @State private var discussionPoints: [String]
    @State private var emotions: [EmotionEntry]
    @State private var journalEntry: String
    @State private var gifts: [Gift]
    @State private var physicalTouchMoments: [PhysicalTouchMoment]
    @State private var showingAppleIntelligenceAnalysis = false
    
    // Location and date type editing
    @State private var location: String
    @State private var latitude: Double?
    @State private var longitude: Double?
    @State private var dateValue: Date
    @State private var timeValue: Date
    @State private var dateType: DateType
    @State private var showingLocationSearch = false
    
    // State for adding new items
    @State private var newDiscussionPoint = ""
    @State private var showingEmotionPicker = false
    @State private var showingGiftForm = false
    @State private var showingTouchForm = false
    
    init(person: DatePerson, date: PreviousDate) {
        self.person = person
        self.date = date
        self._discussionPoints = State(initialValue: date.discussionPoints)
        self._emotions = State(initialValue: date.emotions)
        self._journalEntry = State(initialValue: date.journalEntry)
        self._gifts = State(initialValue: date.gifts)
        self._physicalTouchMoments = State(initialValue: date.physicalTouchMoments)
        self._location = State(initialValue: date.location)
        self._latitude = State(initialValue: date.latitude)
        self._longitude = State(initialValue: date.longitude)
        self._dateValue = State(initialValue: date.date)
        self._timeValue = State(initialValue: date.time)
        self._dateType = State(initialValue: date.dateType ?? .dinner)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppStyle.Colors.background(for: colorScheme)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        dateHeaderView
                        
                        // Location and Time Section
                        locationTimeSection
                        
                        // Discussion Points Section
                        discussionPointsSection
                        
                        // Emotions Section
                        emotionsSection
                        
                        // Journal Entry Section
                        journalEntrySection
                        
                        // Gifts Section
                        giftsSection
                        
                        // Physical Touch Section
                        physicalTouchSection
                        
                        // Apple Intelligence Analysis Button
                        appleIntelligenceButton
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 32)
                }
            }
            .navigationBarHidden(true)
        }
        .onDisappear {
            saveChanges()
        }
        .sheet(isPresented: $showingEmotionPicker) {
            EmotionPickerView { newEmotions in
                emotions.append(contentsOf: newEmotions)
            }
        }
        .sheet(isPresented: $showingGiftForm) {
            GiftFormView { gift in
                gifts.append(gift)
            }
        }
        .sheet(isPresented: $showingTouchForm) {
            PhysicalTouchFormView { touch in
                physicalTouchMoments.append(touch)
            }
        }
        .sheet(isPresented: $showingLocationSearch) {
            LocationSearchView(
                selectedLocation: $location,
                selectedLatitude: $latitude,
                selectedLongitude: $longitude,
                isPresented: $showingLocationSearch
            )
        }
        .sheet(isPresented: $showingAppleIntelligenceAnalysis) {
            DateIntelligenceAnalysisView(person: person, date: date)
        }
    }
    
    // MARK: - Header
    private var dateHeaderView: some View {
        VStack(spacing: 16) {
            HStack {
                Button("BACK") {
                    dismiss()
                }
                .font(AppStyle.Fonts.caption)
                .foregroundColor(AppStyle.Colors.accent)
                
                Spacer()
            }
            
            VStack(spacing: 8) {
                Text("DATE WITH \(person.name.uppercased())")
                    .font(AppStyle.Fonts.title)
                    .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                    .multilineTextAlignment(.center)
                
                Text(date.location.uppercased())
                    .font(AppStyle.Fonts.heading)
                    .foregroundColor(AppStyle.Colors.accent)
                    .multilineTextAlignment(.center)
                
                HStack {
                    Text(date.date.formatted(date: .abbreviated, time: .omitted))
                        .font(AppStyle.Fonts.body)
                        .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                    
                    Text("•")
                        .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                    
                    Text(date.time.formatted(date: .omitted, time: .shortened))
                        .font(AppStyle.Fonts.body)
                        .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                }
            }
        }
    }
    
    // MARK: - Location and Time Section
    private var locationTimeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("LOCATION, DATE & TIME")
                .font(AppStyle.Fonts.heading)
                .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
            
            VStack(spacing: 16) {
                // Date Type
                VStack(alignment: .leading, spacing: 8) {
                    Text("DATE TYPE")
                        .font(AppStyle.Fonts.body)
                        .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(DateType.allCases, id: \.self) { type in
                                Button {
                                    dateType = type
                                } label: {
                                    Text(type.rawValue.uppercased())
                                        .font(AppStyle.Fonts.caption)
                                        .foregroundColor(dateType == type ? .white : AppStyle.Colors.textPrimary(for: colorScheme))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(dateType == type ? AppStyle.Colors.accent : AppStyle.Colors.surface(for: colorScheme))
                                        .overlay {
                                            Rectangle()
                                                .stroke(dateType == type ? AppStyle.Colors.accent : AppStyle.Colors.borderColor, lineWidth: AppStyle.Layout.borderWidth)
                                        }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                
                // Location with search button
                VStack(alignment: .leading, spacing: 8) {
                    Text("LOCATION")
                        .font(AppStyle.Fonts.body)
                        .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                    
                    Button {
                        showingLocationSearch = true
                    } label: {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(AppStyle.Colors.accent)
                            
                            Text(location.isEmpty ? "TAP TO SELECT LOCATION" : location.uppercased())
                                .font(AppStyle.Fonts.body)
                                .foregroundColor(location.isEmpty ? AppStyle.Colors.textSecondary(for: colorScheme) : AppStyle.Colors.textPrimary(for: colorScheme))
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                        }
                        .padding(16)
                        .background(AppStyle.Colors.surface(for: colorScheme))
                        .overlay {
                            Rectangle()
                                .stroke(AppStyle.Colors.borderColor, lineWidth: AppStyle.Layout.borderWidth)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Open in Maps button if location exists
                    if !location.isEmpty && latitude != nil && longitude != nil {
                        Button {
                            date.openInAppleMaps()
                        } label: {
                            HStack {
                                Image(systemName: "map.fill")
                                Text("OPEN IN APPLE MAPS")
                            }
                            .font(AppStyle.Fonts.caption)
                            .foregroundColor(AppStyle.Colors.accent)
                        }
                        .padding(.top, 4)
                    }
                }
                
                // Date and Time pickers
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("DATE")
                            .font(AppStyle.Fonts.body)
                            .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                        
                        DatePicker("", selection: $dateValue, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .padding(12)
                            .background(AppStyle.Colors.surface(for: colorScheme))
                            .overlay {
                                Rectangle()
                                    .stroke(AppStyle.Colors.borderColor, lineWidth: AppStyle.Layout.borderWidth)
                            }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("TIME")
                            .font(AppStyle.Fonts.body)
                            .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                        
                        DatePicker("", selection: $timeValue, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .padding(12)
                            .background(AppStyle.Colors.surface(for: colorScheme))
                            .overlay {
                                Rectangle()
                                    .stroke(AppStyle.Colors.borderColor, lineWidth: AppStyle.Layout.borderWidth)
                            }
                    }
                }
            }
        }
        .neobrutalistCard()
    }
    
    // MARK: - Discussion Points Section
    private var discussionPointsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("DISCUSSION POINTS")
                    .font(AppStyle.Fonts.heading)
                    .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                Spacer()
            }
            
            // Add new discussion point
            HStack {
                TextField("Add discussion point...", text: $newDiscussionPoint)
                    .textFieldStyle(CustomTextFieldStyle())
                
                Button("ADD") {
                    if !newDiscussionPoint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        discussionPoints.append(newDiscussionPoint.trimmingCharacters(in: .whitespacesAndNewlines))
                        newDiscussionPoint = ""
                    }
                }
                .font(AppStyle.Fonts.caption)
                .foregroundColor(AppStyle.Colors.accent)
            }
            
            // Existing discussion points
            ForEach(Array(discussionPoints.enumerated()), id: \.offset) { index, point in
                HStack {
                    Text("• \(point)")
                        .font(AppStyle.Fonts.body)
                        .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                    Spacer()
                    Button("Remove") {
                        discussionPoints.remove(at: index)
                    }
                    .font(AppStyle.Fonts.caption)
                    .foregroundColor(.red)
                }
                .padding(.vertical, 4)
            }
            
            if discussionPoints.isEmpty && newDiscussionPoint.isEmpty {
                Text("What did you talk about?")
                    .font(AppStyle.Fonts.body)
                    .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                    .italic()
            }
        }
        .neobrutalistCard()
    }
    
    // MARK: - Emotions Section
    private var emotionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("FEELINGS & EMOTIONS")
                    .font(AppStyle.Fonts.heading)
                    .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                Spacer()
                Button("ADD") {
                    showingEmotionPicker = true
                }
                .font(AppStyle.Fonts.caption)
                .foregroundColor(AppStyle.Colors.accent)
            }
            
            if emotions.isEmpty {
                Text("How did this date make you feel?")
                    .font(AppStyle.Fonts.body)
                    .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                    .italic()
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 12)], spacing: 12) {
                    ForEach(Array(emotions.enumerated()), id: \.offset) { index, emotion in
                        EmotionCardView(emotion: emotion) {
                            emotions.remove(at: index)
                        }
                    }
                }
            }
        }
        .neobrutalistCard()
    }
    
    // MARK: - Journal Entry Section
    private var journalEntrySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("JOURNAL ENTRY")
                .font(AppStyle.Fonts.heading)
                .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
            
            ZStack(alignment: .topLeading) {
                if journalEntry.isEmpty {
                    Text("How was the date? What did you do? How did it make you feel? Any memorable moments?")
                        .font(AppStyle.Fonts.body)
                        .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                        .padding(16)
                        .allowsHitTesting(false)
                }
                
                TextEditor(text: $journalEntry)
                    .font(AppStyle.Fonts.body)
                    .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                    .frame(minHeight: 120)
                    .padding(12)
                    .background(AppStyle.Colors.surface(for: colorScheme))
                    .overlay {
                        Rectangle()
                            .stroke(AppStyle.Colors.borderColor, lineWidth: AppStyle.Layout.borderWidth)
                    }
            }
        }
        .neobrutalistCard()
    }
    
    // MARK: - Gifts Section
    private var giftsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("GIFTS EXCHANGED")
                    .font(AppStyle.Fonts.heading)
                    .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                Spacer()
                Button("ADD") {
                    showingGiftForm = true
                }
                .font(AppStyle.Fonts.caption)
                .foregroundColor(AppStyle.Colors.accent)
            }
            
            if gifts.isEmpty {
                Text("Any gifts given or received?")
                    .font(AppStyle.Fonts.body)
                    .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                    .italic()
            } else {
                ForEach(Array(gifts.enumerated()), id: \.offset) { index, gift in
                    GiftCardView(gift: gift) {
                        gifts.remove(at: index)
                    }
                }
            }
        }
        .neobrutalistCard()
    }
    
    // MARK: - Physical Touch Section
    private var physicalTouchSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("PHYSICAL TOUCH MOMENTS")
                    .font(AppStyle.Fonts.heading)
                    .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                Spacer()
                Button("ADD") {
                    showingTouchForm = true
                }
                .font(AppStyle.Fonts.caption)
                .foregroundColor(AppStyle.Colors.accent)
            }
            
            if physicalTouchMoments.isEmpty {
                Text("Any physical touch moments to remember?")
                    .font(AppStyle.Fonts.body)
                    .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                    .italic()
            } else {
                ForEach(Array(physicalTouchMoments.enumerated()), id: \.offset) { index, touch in
                    PhysicalTouchCardView(touch: touch) {
                        physicalTouchMoments.remove(at: index)
                    }
                }
            }
        }
        .neobrutalistCard()
    }
    
    // MARK: - Apple Intelligence Button
    private var appleIntelligenceButton: some View {
        Button("APPLE INTELLIGENCE ANALYSIS") {
            showingAppleIntelligenceAnalysis = true
        }
        .buttonStyle(PrimaryButtonStyle())
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Save Changes
    private func saveChanges() {
        date.discussionPoints = discussionPoints
        date.emotions = emotions
        date.journalEntry = journalEntry
        date.gifts = gifts
        date.physicalTouchMoments = physicalTouchMoments
        date.location = location
        date.latitude = latitude
        date.longitude = longitude
        date.date = dateValue
        date.time = timeValue
        date.dateType = dateType
        
        do {
            try modelContext.save()
            print("Date details saved successfully")
        } catch {
            print("Error saving date details: \(error)")
        }
    }
}

// MARK: - Supporting Views

struct EmotionCardView: View {
    let emotion: EmotionEntry
    let onRemove: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Spacer()
                Button("×") {
                    onRemove()
                }
                .font(.caption)
                .foregroundColor(.red)
            }
            .frame(height: 16)
            
            Image(systemName: emotion.emotionType.systemImage)
                .font(.system(size: 24))
                .foregroundColor(emotion.emotionType.color)
            
            Text(emotion.emotionType.rawValue)
                .font(AppStyle.Fonts.caption)
                .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                .multilineTextAlignment(.center)
            
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= emotion.intensity ? "star.fill" : "star")
                        .font(.system(size: 8))
                        .foregroundColor(emotion.emotionType.color)
                }
            }
        }
        .padding(12)
        .background(emotion.emotionType.color.opacity(0.1))
        .overlay {
            Rectangle()
                .stroke(emotion.emotionType.color, lineWidth: 2)
        }
    }
}

struct GiftCardView: View {
    let gift: Gift
    let onRemove: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: gift.giver == "me" ? "gift" : "gift.fill")
                    .foregroundColor(AppStyle.Colors.accent)
                
                Text(gift.item)
                    .font(AppStyle.Fonts.body)
                    .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                
                Spacer()
                
                Text(gift.giver == "me" ? "Given by me" : "Received from them")
                    .font(AppStyle.Fonts.caption)
                    .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                
                Button("Remove") {
                    onRemove()
                }
                .font(AppStyle.Fonts.caption)
                .foregroundColor(.red)
            }
            
            if !gift.giftDescription.isEmpty {
                Text(gift.giftDescription)
                    .font(AppStyle.Fonts.caption)
                    .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
            }
        }
        .padding(12)
        .background(AppStyle.Colors.surface(for: colorScheme))
        .overlay {
            Rectangle()
                .stroke(AppStyle.Colors.borderColor, lineWidth: AppStyle.Layout.borderWidth)
        }
    }
}

struct PhysicalTouchCardView: View {
    let touch: PhysicalTouchMoment
    let onRemove: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: touch.touchType.systemImage)
                    .foregroundColor(AppStyle.Colors.accent)
                
                Text(touch.touchType.rawValue)
                    .font(AppStyle.Fonts.body)
                    .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                
                Spacer()
                
                Text(touch.duration.capitalized)
                    .font(AppStyle.Fonts.caption)
                    .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                
                Button("Remove") {
                    onRemove()
                }
                .font(AppStyle.Fonts.caption)
                .foregroundColor(.red)
            }
            
            if !touch.context.isEmpty {
                Text(touch.context)
                    .font(AppStyle.Fonts.caption)
                    .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
            }
        }
        .padding(12)
        .background(AppStyle.Colors.surface(for: colorScheme))
        .overlay {
            Rectangle()
                .stroke(AppStyle.Colors.borderColor, lineWidth: AppStyle.Layout.borderWidth)
        }
    }
}

#Preview {
    let person = DatePerson(name: "Sarah", meetingDate: Date())
    let date = PreviousDate(location: "Central Park", date: Date(), time: Date())
    
    DateDetailView(person: person, date: date)
        .modelContainer(for: DatePerson.self, inMemory: true)
}
