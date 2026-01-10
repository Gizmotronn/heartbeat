//
//  AddDateHeaderView.swift
//  Heartbeat
//
//  Created by Liam Arbuckle on 8/1/2026.
//

import SwiftUI

struct AddDateHeaderView: View {
    let personName: String
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Text("ADD DATE WITH \(personName.uppercased())")
            .font(AppStyle.Fonts.heading)
            .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
            .multilineTextAlignment(.center)
    }
}