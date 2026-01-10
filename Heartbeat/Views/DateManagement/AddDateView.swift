//
//  AddDateView.swift
//  Heartbeat
//
//  Created by Liam Arbuckle on 8/1/2026.
//

import SwiftUI
import SwiftData
import MapKit

struct AddDateView: View {
    let person: DatePerson
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    
    @State private var location = ""
    @State private var latitude: Double?
    @State private var longitude: Double?
    @State private var date = {
        Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    }()
    @State private var time = Date()
    @State private var notes = ""
    @State private var dateType: DateType = .dinner
    @State private var showingLocationSearch = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppStyle.Colors.background(for: colorScheme)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    AddDateHeaderView(personName: person.name)
                    
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
                    
                    AddDateActionButtons(
                        location: location,
                        onCancel: { dismiss() },
                        onSave: { saveDate() }
                    )
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
    }
    
    private func saveDate() {
        let newDate = PreviousDate(
            location: location,
            latitude: latitude,
            longitude: longitude,
            date: date,
            time: time,
            notes: notes,
            dateType: dateType
        )
        
        person.previousDates.append(newDate)
        
        do {
            try modelContext.save()
            
            let modelDescriptor = FetchDescriptor<DatePerson>()
            let allPeople = try modelContext.fetch(modelDescriptor)
            WidgetDataManager.updateWidgetData(from: allPeople)
            
        } catch {
            print("Error saving date: \(error)")
        }
        
        dismiss()
    }
}