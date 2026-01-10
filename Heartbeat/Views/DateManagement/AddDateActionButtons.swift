//
//  AddDateActionButtons.swift
//  Heartbeat
//
//  Created by Liam Arbuckle on 8/1/2026.
//

import SwiftUI

struct AddDateActionButtons: View {
    let location: String
    let onCancel: () -> Void
    let onSave: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Button("CANCEL") {
                onCancel()
            }
            .buttonStyle(SecondaryButtonStyle())
            
            Spacer()
            
            Button("SAVE DATE") {
                onSave()
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(location.isEmpty)
        }
    }
}