//
//  HomeView.swift
//  Heartbeat
//
//  Created by Liam Arbuckle on 8/1/2026.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var datePeople: [DatePerson]
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var showingOnboarding = false
    @State private var showingArchive = false
    
    // Computed property to find the current person (most recent date, not archived)
    private var currentPerson: DatePerson? {
        return datePeople.filter { !$0.isArchived }.max { person1, person2 in
            let person1LastDate = person1.previousDates.map(\.date).max() ?? person1.meetingDate
            let person2LastDate = person2.previousDates.map(\.date).max() ?? person2.meetingDate
            return person1LastDate < person2LastDate
        }
    }

    // Computed property to get archived people (isArchived == true)
    private var archivedPeople: [DatePerson] {
        return datePeople.filter { $0.isArchived }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppStyle.Colors.background(for: colorScheme)
                    .ignoresSafeArea()
                
                if datePeople.isEmpty || (!datePeople.isEmpty && currentPerson == nil) {
                    // Show empty state if there are no people, or all are archived
                    EmptyStateView(showingOnboarding: $showingOnboarding, archivedPeople: archivedPeople)
                } else if let current = currentPerson {
                    // Show current person's profile directly
                    PersonDetailView(person: current)
                } else {
                    // Fallback (shouldn't happen)
                    Text("NO DATA")
                        .font(AppStyle.Fonts.body)
                        .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                }
            }
            .navigationTitle("HEARTBEAT")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !datePeople.isEmpty && !archivedPeople.isEmpty {
                        Button("ARCHIVE") {
                            showingArchive = true
                        }
                        .foregroundColor(AppStyle.Colors.accent)
                    }
                }
                
                // Only show the "add new person" button when there are no people (empty state)
                if datePeople.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingOnboarding = true
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(AppStyle.Colors.accent)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingOnboarding) {
            OnboardingFlow()
        }
        .sheet(isPresented: $showingArchive) {
            ArchiveView(archivedPeople: archivedPeople)
        }
        .onAppear {
            // Update widget data when app loads
            WidgetDataManager.updateWidgetData(from: datePeople)
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: DatePerson.self, inMemory: true)
}