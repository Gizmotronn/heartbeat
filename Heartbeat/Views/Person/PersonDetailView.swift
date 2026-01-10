//
//  PersonDetailView.swift
//  Heartbeat
//
//  Created by Liam Arbuckle on 8/1/2026.
//

import SwiftUI
import SwiftData

struct PersonDetailView: View {
    let person: DatePerson
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddDate = false
    @State private var showingAppleIntelligenceOverview = false
    
    var body: some View {
        ZStack {
            AppStyle.Colors.background(for: colorScheme)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header with photo and basic info
                    PersonHeaderView(person: person)
                    
                    // Upcoming dates section
                    let upcomingDates = person.previousDates.filter { $0.fullDateTime > Date() }
                    if !upcomingDates.isEmpty {
                        UpcomingDatesView(person: person)
                    }
                    
                    // Previous dates section
                    let pastDates = person.previousDates.filter { $0.fullDateTime <= Date() }
                    if !pastDates.isEmpty {
                        PreviousDatesView(person: person)
                    }
                    
                    Spacer(minLength: 150)
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
            }
            
            // Apple Intelligence button at bottom
            VStack {
                Spacer()
                
                Button("APPLE INTELLIGENCE OVERVIEW") {
                    showingAppleIntelligenceOverview = true
                }
                .buttonStyle(PrimaryButtonStyle())
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppStyle.Colors.background(for: colorScheme))
            }
        }
        .background(AppStyle.Colors.background(for: colorScheme))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddDate = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(AppStyle.Colors.accent)
                }
            }
        }
        .sheet(isPresented: $showingAddDate) {
            AddDateView(person: person)
        }
        .sheet(isPresented: $showingAppleIntelligenceOverview) {
            AppleIntelligenceOverviewView(person: person)
        }
    }
    
    private func openIMessage(phoneNumber: String) {
        let cleanedPhoneNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if let url = URL(string: "sms:\(cleanedPhoneNumber)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openInMaps(location: String, latitude: Double?, longitude: Double?) {
        if let lat = latitude, let lon = longitude {
            let url = URL(string: "maps://?q=\(lat),\(lon)")
            if let url = url, UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        } else {
            let encodedLocation = location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            if let url = URL(string: "maps://?q=\(encodedLocation)") {
                UIApplication.shared.open(url)
            }
        }
    }
}