//
//  SharedComponents.swift
//  Heartbeat
//
//  Created by Liam Arbuckle on 8/1/2026.
//

import SwiftUI

struct CustomTextFieldStyle: TextFieldStyle {
    @Environment(\.colorScheme) private var colorScheme
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(AppStyle.Fonts.body)
            .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
            .padding(16)
            .background(AppStyle.Colors.surface(for: colorScheme))
            .overlay {
                Rectangle()
                    .stroke(AppStyle.Colors.borderColor, lineWidth: AppStyle.Layout.borderWidth)
            }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppStyle.Fonts.body)
            .foregroundColor(.white)
            .padding(AppStyle.Layout.buttonPadding)
            .background(isEnabled ? AppStyle.Colors.accent : AppStyle.Colors.textSecondary(for: colorScheme))
            .overlay {
                Rectangle()
                    .stroke(AppStyle.Colors.borderColor, lineWidth: AppStyle.Layout.borderWidth)
            }
            .offset(
                x: configuration.isPressed ? 3 : 0,
                y: configuration.isPressed ? 3 : 0
            )
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppStyle.Fonts.body)
            .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
            .padding(AppStyle.Layout.buttonPadding)
            .background(AppStyle.Colors.surface(for: colorScheme))
            .overlay {
                Rectangle()
                    .stroke(AppStyle.Colors.borderColor, lineWidth: AppStyle.Layout.borderWidth)
            }
            .offset(
                x: configuration.isPressed ? 3 : 0,
                y: configuration.isPressed ? 3 : 0
            )
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
