// DateCreationViewModel.swift
// ViewModel for the typeform-style date creation flow

import Foundation
import SwiftUI
import Combine

class DateCreationViewModel: ObservableObject {
    @Published var isPastDate: Bool? = nil
    @Published var date: Date = Date()
    @Published var time: Date = Date()
    @Published var location: String = ""
    @Published var latitude: Double?
    @Published var longitude: Double?
    @Published var dateType: DateType = .dinner
    @Published var discussionPoints: String = ""
    @Published var feelings: [EmotionEntry] = []
    @Published var journalEntry: String = ""
    @Published var gifts: [Gift] = []
    @Published var physicalTouchMoments: [PhysicalTouchMoment] = []

    @Published var currentStepIndex: Int = 0

    var steps: [DateCreationStep] {
        DateCreationStep.steps(forPastDate: isPastDate ?? false)
    }

    func nextStep() {
        if currentStepIndex < steps.count - 1 {
            currentStepIndex += 1
        }
    }

    func previousStep() {
        if currentStepIndex > 0 {
            currentStepIndex -= 1
        }
    }

    func reset() {
        isPastDate = nil
        date = Date()
        time = Date()
        location = ""
        latitude = nil
        longitude = nil
        dateType = .dinner
        discussionPoints = ""
        feelings = []
        journalEntry = ""
        gifts = []
        physicalTouchMoments = []
        currentStepIndex = 0
    }
}
