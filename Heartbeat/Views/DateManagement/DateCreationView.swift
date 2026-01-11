// DateCreationView.swift
// Typeform-style step-by-step date creation UI

import SwiftUI
import SwiftData

struct DateCreationView: View {
    @ObservedObject var viewModel: DateCreationViewModel
    let person: DatePerson
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingLocationSearch = false
    
    var body: some View {
        VStack {
            stepContent
            Spacer()
            HStack {
                if viewModel.currentStepIndex > 0 {
                    Button("Back") { viewModel.previousStep() }
                        .buttonStyle(SecondaryButtonStyle())
                }
                Spacer()
                if viewModel.currentStepIndex < viewModel.steps.count - 1 {
                    Button("Next") { handleNext() }
                        .buttonStyle(PrimaryButtonStyle())
                } else {
                    Button("Save Date") { saveDate() }
                        .buttonStyle(PrimaryButtonStyle())
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingLocationSearch) {
            LocationSearchView(
                selectedLocation: $viewModel.location,
                selectedLatitude: $viewModel.latitude,
                selectedLongitude: $viewModel.longitude,
                isPresented: $showingLocationSearch
            )
        }
        .padding()
    }
    
    @ViewBuilder
    var stepContent: some View {
        switch viewModel.steps[viewModel.currentStepIndex] {
        case .pastOrFuture:
            VStack(spacing: 24) {
                Text("Is this a past or future date?")
                    .font(.title2)
                HStack {
                    Button("Past Date") {
                        viewModel.isPastDate = true
                        viewModel.nextStep()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    Button("Planned Date") {
                        viewModel.isPastDate = false
                        viewModel.nextStep()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            }
        case .dateTime:
            VStack(spacing: 24) {
                Text("Add Date & Time")
                    .font(.title2)
                DatePicker("Date", selection: $viewModel.date, displayedComponents: [.date])
                    .datePickerStyle(GraphicalDatePickerStyle())
                DatePicker("Time", selection: $viewModel.time, displayedComponents: [.hourAndMinute])
                    .datePickerStyle(WheelDatePickerStyle())
            }
        case .location:
            VStack(spacing: 24) {
                Text("Add Location")
                    .font(.title2)
                Button(action: { showingLocationSearch = true }) {
                    HStack {
                        Text(viewModel.location.isEmpty ? "Tap to search location" : viewModel.location)
                        Spacer()
                        Image(systemName: "magnifyingglass")
                    }
                    .padding()
                    .background(AppStyle.Colors.surface(for: colorScheme))
                    .cornerRadius(8)
                }
            }
        case .dateType:
            VStack(spacing: 24) {
                Text("Select Date Type")
                    .font(.title2)
                DateTypePickerView(dateType: $viewModel.dateType, isEditing: true)
            }
        case .discussionPoints:
            VStack(spacing: 24) {
                Text("Discussion Points")
                    .font(.title2)
                TextField("What did you talk about?", text: $viewModel.discussionPoints, axis: .vertical)
                    .textFieldStyle(CustomTextFieldStyle())
                    .lineLimit(3...6)
            }
        case .feelings:
            EmotionPickerStepView(selectedEmotions: $viewModel.feelings)
        case .journalEntry:
            VStack(spacing: 24) {
                Text("Journal Entry")
                    .font(.title2)
                TextField("Write about the date...", text: $viewModel.journalEntry, axis: .vertical)
                    .textFieldStyle(CustomTextFieldStyle())
                    .lineLimit(5...10)
            }
        case .gifts:
            GiftStepView(gifts: $viewModel.gifts)
        case .physicalTouch:
            PhysicalTouchStepView(touches: $viewModel.physicalTouchMoments)
        }
    }
    
    func handleNext() {
        // Optionally add validation here
        viewModel.nextStep()
    }
    
    func saveDate() {
        // Actually save the date to the person
        let newDate = PreviousDate(
            location: viewModel.location,
            latitude: viewModel.latitude,
            longitude: viewModel.longitude,
            date: viewModel.date,
            time: viewModel.time,
            notes: "", // Optionally add notes field to the typeform flow
            dateType: viewModel.dateType,
            discussionPoints: viewModel.discussionPoints.isEmpty ? [] : [viewModel.discussionPoints],
            emotions: viewModel.feelings,
            journalEntry: viewModel.journalEntry,
            gifts: viewModel.gifts,
            physicalTouchMoments: viewModel.physicalTouchMoments
        )
        person.previousDates.append(newDate)
        // Save to model context if available
        if let modelContext = try? person.modelContext {
            do {
                try modelContext.save()
            } catch {
                print("Error saving date: \(error)")
            }
        }
        dismiss()
    }
}

// Step wrappers for custom pickers
struct EmotionPickerStepView: View {
    @Binding var selectedEmotions: [EmotionEntry]
    @State private var showingPicker = false
    var body: some View {
        VStack(spacing: 24) {
            Text("Feelings & Emotions")
                .font(.title2)
            Button("Add Emotions") { showingPicker = true }
                .buttonStyle(PrimaryButtonStyle())
            if !selectedEmotions.isEmpty {
                ForEach(selectedEmotions, id: \.emotionType) { entry in
                    HStack {
                        Text(entry.emotionType.rawValue)
                        Spacer()
                        Text("\(entry.intensity)★")
                    }
                }
            }
        }
        .sheet(isPresented: $showingPicker) {
            EmotionPickerView { emotions in
                selectedEmotions = emotions
            }
        }
    }
}

struct GiftStepView: View {
    @Binding var gifts: [Gift]
    @State private var showingGiftForm = false
    var body: some View {
        VStack(spacing: 24) {
            Text("Gifts Exchanged")
                .font(.title2)
            Button("Add Gift") { showingGiftForm = true }
                .buttonStyle(PrimaryButtonStyle())
            if !gifts.isEmpty {
                ForEach(gifts, id: \.item) { gift in
                    HStack {
                        Text(gift.item)
                        Spacer()
                        Text(gift.giver)
                    }
                }
            }
        }
        .sheet(isPresented: $showingGiftForm) {
            GiftFormView { gift in
                gifts.append(gift)
            }
        }
    }
}

struct PhysicalTouchStepView: View {
    @Binding var touches: [PhysicalTouchMoment]
    @State private var showingTouchForm = false
    var body: some View {
        VStack(spacing: 24) {
            Text("Physical Touch Moments")
                .font(.title2)
            Button("Add Moment") { showingTouchForm = true }
                .buttonStyle(PrimaryButtonStyle())
            if !touches.isEmpty {
                ForEach(touches, id: \.touchType) { touch in
                    HStack {
                        Text(touch.touchType.rawValue)
                        Spacer()
                        Text(touch.duration.capitalized)
                    }
                }
            }
        }
        .sheet(isPresented: $showingTouchForm) {
            PhysicalTouchFormView { touch in
                touches.append(touch)
            }
        }
    }
}
