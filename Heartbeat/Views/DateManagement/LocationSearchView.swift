//
//  LocationSearchView.swift
//  Heartbeat
//
//  Created by Liam Arbuckle on 8/1/2026.
//

import SwiftUI
import MapKit
import Contacts

struct LocationSearchView: View {
    @Binding var selectedLocation: String
    @Binding var selectedLatitude: Double?
    @Binding var selectedLongitude: Double?
    @Binding var isPresented: Bool
    
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching = false
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                AppStyle.Colors.background(for: colorScheme)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 16) {
                        HStack {
                            Button("CANCEL") {
                                isPresented = false
                            }
                            .font(AppStyle.Fonts.body)
                            .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                            
                            Spacer()
                            
                            Text("SEARCH LOCATION")
                                .font(AppStyle.Fonts.body)
                                .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                            
                            Spacer()
                            
                            // Invisible button for balance
                            Button("CANCEL") {
                                // No action
                            }
                            .font(AppStyle.Fonts.body)
                            .foregroundColor(.clear)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        // Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                            
                            TextField("SEARCH FOR A PLACE...", text: $searchText)
                                .font(AppStyle.Fonts.body)
                                .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                                .onChange(of: searchText) { _, newValue in
                                    searchForLocations(query: newValue)
                                }
                        }
                        .padding(16)
                        .background(AppStyle.Colors.surface(for: colorScheme))
                        .overlay {
                            Rectangle()
                                .stroke(AppStyle.Colors.borderColor, lineWidth: AppStyle.Layout.borderWidth)
                        }
                        .shadow(
                            color: AppStyle.Colors.shadowColor,
                            radius: 0,
                            x: 3,
                            y: 3
                        )
                        .padding(.horizontal, 24)
                    }
                    
                    // Search results
                    if isSearching {
                        VStack(spacing: 20) {
                            Spacer()
                            ProgressView()
                                .scaleEffect(1.2)
                                .tint(AppStyle.Colors.accent)
                            Text("SEARCHING...")
                                .font(AppStyle.Fonts.caption)
                                .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                            Spacer()
                        }
                    } else if searchResults.isEmpty && !searchText.isEmpty {
                        VStack(spacing: 20) {
                            Spacer()
                            Image(systemName: "location.slash")
                                .font(.system(size: 48))
                                .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                            Text("NO LOCATIONS FOUND")
                                .font(AppStyle.Fonts.body)
                                .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                            Text("TRY SEARCHING FOR SOMETHING ELSE")
                                .font(AppStyle.Fonts.caption)
                                .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                            Spacer()
                        }
                    } else if !searchResults.isEmpty {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(searchResults.indices, id: \.self) { index in
                                    LocationResultRow(
                                        mapItem: searchResults[index],
                                        onTap: {
                                            selectLocation(searchResults[index])
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 24)
                        }
                    } else {
                        VStack(spacing: 20) {
                            Spacer()
                            Image(systemName: "location")
                                .font(.system(size: 48))
                                .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                            Text("SEARCH FOR A LOCATION")
                                .font(AppStyle.Fonts.body)
                                .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                            Text("START TYPING TO FIND PLACES")
                                .font(AppStyle.Fonts.caption)
                                .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                            Spacer()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func searchForLocations(query: String) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            DispatchQueue.main.async {
                isSearching = false
                
                if let response = response {
                    searchResults = response.mapItems
                } else {
                    searchResults = []
                    print("Error searching for locations: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    private func selectLocation(_ mapItem: MKMapItem) {
        selectedLocation = mapItem.name ?? ""
        selectedLatitude = mapItem.placemark.coordinate.latitude
        selectedLongitude = mapItem.placemark.coordinate.longitude
        isPresented = false
    }
}

struct LocationResultRow: View {
    let mapItem: MKMapItem
    let onTap: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Location icon
                Image(systemName: "location.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppStyle.Colors.accent)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    // Name
                    Text(mapItem.name ?? "Unknown Location")
                        .font(AppStyle.Fonts.body)
                        .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                        .multilineTextAlignment(.leading)
                    
                    // Address
                    if let address = formatAddress(from: mapItem.placemark) {
                        Text(address)
                            .font(AppStyle.Fonts.caption)
                            .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
            }
            .padding(20)
            .background(AppStyle.Colors.surface(for: colorScheme))
            .overlay {
                Rectangle()
                    .stroke(AppStyle.Colors.borderColor, lineWidth: AppStyle.Layout.borderWidth)
            }
            .shadow(
                color: AppStyle.Colors.shadowColor,
                radius: 0,
                x: 3,
                y: 3
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatAddress(from placemark: CLPlacemark) -> String? {
        var addressComponents: [String] = []
        
        if let thoroughfare = placemark.thoroughfare {
            addressComponents.append(thoroughfare)
        }
        
        if let locality = placemark.locality {
            addressComponents.append(locality)
        }
        
        if let administrativeArea = placemark.administrativeArea {
            addressComponents.append(administrativeArea)
        }
        
        return addressComponents.isEmpty ? nil : addressComponents.joined(separator: ", ")
    }
}

#Preview {
    LocationSearchView(
        selectedLocation: .constant(""),
        selectedLatitude: .constant(nil),
        selectedLongitude: .constant(nil),
        isPresented: .constant(true)
    )
}