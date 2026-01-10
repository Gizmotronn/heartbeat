//
//  EditDateView.swift
//  Heartbeat
//
//  Created by Liam Arbuckle on 8/1/2026.
//

import SwiftUI
import SwiftData
import MapKit

struct EditDateView: View {
    let person: DatePerson
    let dateToEdit: PreviousDate
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    
    @State private var location: String
    @State private var latitude: Double?
    @State private var longitude: Double?
    @State private var date: Date
    @State private var time: Date
    @State private var notes: String
    @State private var dateType: DateType
    @State private var showingLocationSearch = false
    @State private var showingDeleteConfirmation = false
    
    init(person: DatePerson, dateToEdit: PreviousDate) {
        self.person = person
        self.dateToEdit = dateToEdit
        self._location = State(initialValue: dateToEdit.location)
        self._latitude = State(initialValue: dateToEdit.latitude)
        self._longitude = State(initialValue: dateToEdit.longitude)
        self._date = State(initialValue: dateToEdit.date)
        self._time = State(initialValue: dateToEdit.time)
        self._notes = State(initialValue: dateToEdit.notes)
        self._dateType = State(initialValue: dateToEdit.dateType ?? .dinner)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppStyle.Colors.background(for: colorScheme)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("EDIT DATE WITH \(person.name.uppercased())")
                        .font(AppStyle.Fonts.heading)
                        .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                        .multilineTextAlignment(.center)
                    
                    AddDateFormView(
                        location: $location,
                        latitude: $latitude,
                        longitude: $longitude,
                        date: $date,
                        time: $time,
                        notes: $notes,
                        dateType: $dateType,
                        showingLocationSearch: $showingLocationSearch
                    )
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        // Delete button
                        Button("DELETE DATE") {
                            showingDeleteConfirmation = true
                        }
                        .buttonStyle(DestructiveButtonStyle())
                        
                        // Save/Cancel buttons
                        HStack(spacing: 16) {
                            Button("CANCEL") {
                                dismiss()
                            }
                            .buttonStyle(SecondaryButtonStyle())
                            
                            Spacer()
                            
                            Button("SAVE CHANGES") {
                                saveChanges()
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .disabled(location.isEmpty)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingLocationSearch) {
            LocationSearchView(
                selectedLocation: $location,
                selectedLatitude: $latitude,
                selectedLongitude: $longitude,
                isPresented: $showingLocationSearch
            )
        }
        .alert("Delete Date", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                deleteDate()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this date? This action cannot be undone.")
        }
    }
    
    private func saveChanges() {
        dateToEdit.location = location
        dateToEdit.latitude = latitude
        dateToEdit.longitude = longitude
        dateToEdit.date = date
        dateToEdit.time = time
        dateToEdit.notes = notes
        dateToEdit.dateType = dateType
        
        do {
            try modelContext.save()            
            let modelDescriptor = FetchDescriptor<DatePerson>()
            let allPeople = try modelContext.fetch(modelDescriptor)
            WidgetDataManager.updateWidgetData(from: allPeople)
                    } catch {
            print("Error saving date changes: \(error)")
        }
        
        dismiss()
    }
    
    private func deleteDate() {
        if let index = person.previousDates.firstIndex(where: { $0.location == dateToEdit.location && $0.fullDateTime == dateToEdit.fullDateTime }) {
            person.previousDates.remove(at: index)
            
            do {
                try modelContext.save()
                
                // Update widget data after deleting date
                let modelDescriptor = FetchDescriptor<DatePerson>()
                let allPeople = try modelContext.fetch(modelDescriptor)
                WidgetDataManager.updateWidgetData(from: allPeople)
                
            } catch {
                print("Error deleting date: \(error)")
            }
        }
        
        dismiss()
    }
}

struct DestructiveButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .neobrutalistButton(
                backgroundColor: .red,
                foregroundColor: .white,
                isPressed: configuration.isPressed
            )
    }
}