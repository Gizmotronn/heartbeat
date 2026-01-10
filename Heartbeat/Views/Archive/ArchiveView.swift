//
//  ArchiveView.swift
//  Heartbeat
//
//  Created by Liam Arbuckle on 8/1/2026.
//

import SwiftUI

struct ArchiveView: View {
    let archivedPeople: [DatePerson]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                AppStyle.Colors.background(for: colorScheme)
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(archivedPeople.sorted(by: { person1, person2 in
                            let date1 = person1.previousDates.map(\.date).max() ?? person1.meetingDate
                            let date2 = person2.previousDates.map(\.date).max() ?? person2.meetingDate
                            return date1 > date2
                        })) { person in
                            NavigationLink {
                                PersonDetailView(person: person)
                            } label: {
                                PersonRowView(person: person)
                                    .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
            }
            .navigationTitle("ARCHIVE")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("DONE") {
                        dismiss()
                    }
                    .foregroundColor(AppStyle.Colors.accent)
                }
            }
        }
    }
}