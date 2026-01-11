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
    @State private var showingSettings = false
    @State private var showingRename = false
    @State private var showingPhotoPicker = false
    @State private var showingArchiveConfirm = false
    @State private var tempName = ""
    // 0 = No AI, 1 = Review Only, 2 = Full AI
    @State private var aiMode: Int = 2
    
    var body: some View {
        ZStack {
            AppStyle.Colors.background(for: colorScheme)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header with photo and basic info
                    PersonHeaderView(person: person)
                    
                    // Planned dates section (future)
                    let plannedDates = person.previousDates.filter { $0.fullDateTime > Date() }
                    if !plannedDates.isEmpty {
                        UpcomingDatesView(person: person)
                    }

                    // Previous dates section (past)
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
            if aiMode == 2 {
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
        }
        .background(AppStyle.Colors.background(for: colorScheme))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundColor(AppStyle.Colors.accent)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddDate = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(AppStyle.Colors.accent)
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsPanel
        }
        .sheet(isPresented: $showingAddDate) {
            DateCreationView(viewModel: DateCreationViewModel(), person: person)
        }
        .sheet(isPresented: $showingAppleIntelligenceOverview) {
            AppleIntelligenceOverviewView(person: person)
        }
        .sheet(isPresented: $showingPhotoPicker) {
            PhotoInputStep(
                selectedPhoto: .constant(nil),
                photoData: .constant(nil),
                showingPhotoCropper: .constant(false)
            )
        }
        .alert("Archive Person?", isPresented: $showingArchiveConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Archive", role: .destructive) {
                person.isArchived = true
                try? modelContext.save()
                // Navigate to HomeView (shows empty state if no people)
                if let window = UIApplication.shared.windows.first {
                    window.rootViewController = UIHostingController(rootView: HomeView())
                    window.makeKeyAndVisible()
                }
            }
        } message: {
            Text("Are you sure you want to archive this person? You can always view them again later.")
        }
    }

    // Settings panel as a sheet (moved outside struct, no 'private')
    var SettingsPanel: some View {
        NavigationView {
            List {
                Section(header: Text("AI Options")) {
                    Toggle(isOn: Binding(
                        get: { aiMode == 0 },
                        set: { if $0 { aiMode = 0 } else if aiMode == 0 { aiMode = -1 } }
                    )) {
                        Text("NO AI")
                    }
                    Toggle(isOn: Binding(
                        get: { aiMode == 1 },
                        set: { if $0 { aiMode = 1 } else if aiMode == 1 { aiMode = -1 } }
                    )) {
                        Text("AI only for reviewing dates")
                    }
                    Toggle(isOn: Binding(
                        get: { aiMode == 2 },
                        set: { if $0 { aiMode = 2 } else if aiMode == 2 { aiMode = -1 } }
                    )) {
                        Text("AI enabled")
                    }
                }
                Section {
                    Button("Rename Person") {
                        tempName = person.name
                        showingRename = true
                    }
                    Button("Change Photo") {
                        showingPhotoPicker = true
                    }
                    Button("Archive") {
                        showingArchiveConfirm = true
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { showingSettings = false }
                }
            }
            .sheet(isPresented: $showingRename) {
                NavigationView {
                    Form {
                        TextField("Name", text: $tempName)
                    }
                    .navigationTitle("Rename Person")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                if !tempName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    person.name = tempName
                                    showingRename = false
                                    showingSettings = false
                                }
                            }
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showingRename = false }
                        }
                    }
                }
            }
        }
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
