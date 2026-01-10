//
//  OnboardingView.swift
//  Heartbeat
//
//  Created by Liam Arbuckle on 8/1/2026.
//

import SwiftUI
import SwiftData
import PhotosUI

struct OnboardingFlow: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var currentStep = 0
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var showingPhotoCropper = false
    @State private var meetingDate = Date()
    @State private var hasPreviousDates = false
    @State private var previousDates: [PreviousDateInput] = []
    
    private let steps = ["Name", "Phone", "Photo", "Meeting Data", "Previous Dates"]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppStyle.Colors.background(for: colorScheme)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Custom neobrutalist progress bar
                    ProgressBarView(currentStep: currentStep, totalSteps: steps.count)
                    
                    Text("STEP \(currentStep + 1) OF \(steps.count)")
                        .font(AppStyle.Fonts.title)
                        .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                    
                    // Step content
                    stepContent
                    
                    Spacer()
                    
                    // Navigation buttons
                    NavigationButtonsView(
                        currentStep: currentStep,
                        totalSteps: steps.count,
                        canProceed: canProceed,
                        onBack: { currentStep -= 1 },
                        onNext: { currentStep += 1 },
                        onFinish: finishOnboarding
                    )
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
            .navigationBarHidden(true)
        }
    }
    
    @ViewBuilder
    private var stepContent: some View {
        Group {
            switch currentStep {
            case 0:
                NameInputStep(name: $name)
            case 1:
                PhoneInputStep(phoneNumber: $phoneNumber)
            case 2:
                PhotoInputStep(
                    selectedPhoto: $selectedPhoto,
                    photoData: $photoData,
                    showingPhotoCropper: $showingPhotoCropper
                )
            case 3:
                MeetingDateStep(meetingDate: $meetingDate)
            case 4:
                PreviousDatesStep(
                    hasPreviousDates: $hasPreviousDates,
                    previousDates: $previousDates
                )
            default:
                EmptyView()
            }
        }
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case 0: return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 1: return true // Phone number is optional
        case 2: return true // Photo is optional
        case 3: return true
        case 4: return true
        default: return false
        }
    }
    
    private func finishOnboarding() {
        let datePerson = DatePerson(
            name: name,
            phoneNumber: phoneNumber,
            photoData: photoData,
            meetingDate: meetingDate,
            previousDates: previousDates.map { input in
                PreviousDate(
                    location: input.location,
                    latitude: input.latitude,
                    longitude: input.longitude,
                    date: input.date,
                    time: input.time,
                    notes: input.notes
                )
            }
        )
        
        modelContext.insert(datePerson)
        
        do {
            try modelContext.save()
            
            // Update widget data after creating new person
            let modelDescriptor = FetchDescriptor<DatePerson>()
            let allPeople = try modelContext.fetch(modelDescriptor)
            WidgetDataManager.updateWidgetData(from: allPeople)
            
        } catch {
            print("Error saving: \(error)")
        }
        
        dismiss()
    }
}

struct ProgressBarView: View {
    let currentStep: Int
    let totalSteps: Int
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(AppStyle.Colors.surface(for: colorScheme))
                    .frame(height: 12)
                    .overlay {
                        Rectangle()
                            .stroke(AppStyle.Colors.borderColor, lineWidth: 2)
                    }
                
                Rectangle()
                    .fill(AppStyle.Colors.accent)
                    .frame(
                        width: CGFloat(currentStep) / CGFloat(totalSteps - 1) * geometry.size.width,
                        height: 12
                    )
            }
            .shadow(
                color: AppStyle.Colors.shadowColor,
                radius: 0,
                x: 3,
                y: 3
            )
        }
        .frame(height: 12)
    }
}

struct NavigationButtonsView: View {
    let currentStep: Int
    let totalSteps: Int
    let canProceed: Bool
    let onBack: () -> Void
    let onNext: () -> Void
    let onFinish: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            if currentStep > 0 {
                Button("BACK") {
                    withAnimation {
                        onBack()
                    }
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            
            Spacer()
            
            Button(currentStep == totalSteps - 1 ? "FINISH" : "NEXT") {
                if currentStep == totalSteps - 1 {
                    onFinish()
                } else {
                    withAnimation {
                        onNext()
                    }
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!canProceed)
        }
    }
}
