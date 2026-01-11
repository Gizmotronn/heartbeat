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
    @State private var date = Date()
    @State private var time = Date()
    @State private var notes = ""
    @State private var dateType: DateType = .dinner
    @State private var showingLocationSearch = false
    @State private var dateKind: DateKind = .future
    
    enum DateKind: String, CaseIterable, Identifiable {
        case past = "Past Date"
        case future = "Planned Date"
        var id: String { self.rawValue }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppStyle.Colors.background(for: colorScheme)
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    AddDateHeaderView(personName: person.name)
                        .padding(.top, 48)
                        .padding(.bottom, 16)
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            Picker("Date Type", selection: $dateKind) {
                                ForEach(DateKind.allCases) { kind in
                                    Text(kind.rawValue).tag(kind)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.bottom, 8)
                            .onChange(of: dateKind) { _, newKind in
                                if newKind == .future && date < Date() {
                                    date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
                                } else if newKind == .past && date > Date() {
                                    date = Date()
                                }
                            }
                            
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
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    AddDateActionButtons(
                        location: location,
                        onCancel: { dismiss() },
                        onSave: { saveDate() }
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                    .padding(.top, 8)
                }
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
    // ...existing code...
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
