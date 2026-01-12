//
//  EmptyStateView.swift
//  Heartbeat
//
//  Created by Liam Arbuckle on 8/1/2026.
//

import SwiftUI

struct EmptyStateView: View {
    @Binding var showingOnboarding: Bool
    var archivedPeople: [DatePerson]
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 32) {
            Text("Love is in the air")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding(.top, 16)
            Image("EmptyStateIllustration")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 300, maxHeight: 300)
                .padding(.horizontal, 24)

            if !archivedPeople.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("ARCHIVED")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                    ForEach(archivedPeople, id: \.id) { person in
                        HStack {
                            Text(person.name)
                                .font(.body)
                                .foregroundColor(.gray)
                                .padding(.vertical, 2)
                            Spacer()
                            Button(action: {
                                person.isArchived = false
                                try? (person as? ObservableObject)?.objectWillChange.send()
                            }) {
                                Text("Unarchive")
                                    .font(.caption)
                                    .foregroundColor(.accentColor)
                                    .padding(6)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }

            Button("GET STARTED") {
                showingOnboarding = true
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
}
