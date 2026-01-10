//
//  DateDetailForms.swift
//  Heartbeat
//
//  Created by Liam Arbuckle on 8/1/2026.
//

import SwiftUI

// MARK: - Emotion Picker View
struct EmotionPickerView: View {
    let onEmotionsAdded: ([EmotionEntry]) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var selectedEmotions: [EmotionType: Int] = [:] // EmotionType -> Intensity
    @State private var currentEmotion: EmotionType? = nil
    @State private var currentIntensity: Int = 3
    
    var body: some View {
        NavigationView {
            ZStack {
                AppStyle.Colors.background(for: colorScheme)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        Text("HOW DID YOU FEEL?")
                            .font(AppStyle.Fonts.title)
                            .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                            .multilineTextAlignment(.center)
                        
                        Text("TAP TO SELECT MULTIPLE EMOTIONS")
                            .font(AppStyle.Fonts.caption)
                            .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                        
                        // Selected emotions preview
                        if !selectedEmotions.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("SELECTED (\(selectedEmotions.count))")
                                    .font(AppStyle.Fonts.body)
                                    .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(Array(selectedEmotions.keys), id: \.self) { emotion in
                                            HStack(spacing: 4) {
                                                Image(systemName: emotion.systemImage)
                                                    .foregroundColor(emotion.color)
                                                Text(emotion.rawValue.uppercased())
                                                    .font(AppStyle.Fonts.caption)
                                                Text("(\(selectedEmotions[emotion] ?? 3)★)")
                                                    .font(AppStyle.Fonts.caption)
                                                    .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                                                Button {
                                                    selectedEmotions.removeValue(forKey: emotion)
                                                    if currentEmotion == emotion {
                                                        currentEmotion = nil
                                                    }
                                                } label: {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                                                }
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(emotion.color.opacity(0.2))
                                            .overlay {
                                                Rectangle()
                                                    .stroke(emotion.color, lineWidth: 2)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Emotion selection grid
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 12)], spacing: 16) {
                            ForEach(EmotionType.allCases, id: \.self) { emotion in
                                Button(action: {
                                    if selectedEmotions[emotion] != nil {
                                        // Already selected - tap to edit intensity
                                        currentEmotion = emotion
                                        currentIntensity = selectedEmotions[emotion] ?? 3
                                    } else {
                                        // Not selected - add with default intensity
                                        selectedEmotions[emotion] = 3
                                        currentEmotion = emotion
                                        currentIntensity = 3
                                    }
                                }) {
                                    VStack(spacing: 8) {
                                        ZStack(alignment: .topTrailing) {
                                            Image(systemName: emotion.systemImage)
                                                .font(.system(size: 28))
                                                .foregroundColor(emotion.color)
                                            
                                            if selectedEmotions[emotion] != nil {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.green)
                                                    .offset(x: 8, y: -8)
                                            }
                                        }
                                        
                                        Text(emotion.rawValue)
                                            .font(AppStyle.Fonts.caption)
                                            .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                                            .multilineTextAlignment(.center)
                                            .lineLimit(2)
                                    }
                                    .frame(width: 80, height: 80)
                                    .background(selectedEmotions[emotion] != nil ? emotion.color.opacity(0.2) : AppStyle.Colors.surface(for: colorScheme))
                                    .overlay {
                                        Rectangle()
                                            .stroke(selectedEmotions[emotion] != nil ? emotion.color : AppStyle.Colors.borderColor, lineWidth: selectedEmotions[emotion] != nil ? 3 : AppStyle.Layout.borderWidth)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        // Intensity picker (for currently selected emotion)
                        if let emotion = currentEmotion {
                            VStack(spacing: 16) {
                                Text("INTENSITY FOR \(emotion.rawValue.uppercased())")
                                    .font(AppStyle.Fonts.heading)
                                    .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                                
                                HStack(spacing: 16) {
                                    ForEach(1...5, id: \.self) { value in
                                        Button(action: {
                                            currentIntensity = value
                                            selectedEmotions[emotion] = value
                                        }) {
                                            Image(systemName: value <= currentIntensity ? "star.fill" : "star")
                                                .font(.system(size: 24))
                                                .foregroundColor(emotion.color)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                            .padding()
                            .background(emotion.color.opacity(0.1))
                            .overlay {
                                Rectangle()
                                    .stroke(emotion.color, lineWidth: 2)
                            }
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 32)
                }
                
                // Fixed bottom buttons
                VStack {
                    Spacer()
                    
                    HStack(spacing: 16) {
                        Button("CANCEL") {
                            dismiss()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .frame(maxWidth: .infinity)
                        
                        Button("ADD \(selectedEmotions.count) EMOTION\(selectedEmotions.count == 1 ? "" : "S")") {
                            let emotions = selectedEmotions.map { EmotionEntry(emotionType: $0.key, intensity: $0.value) }
                            onEmotionsAdded(emotions)
                            dismiss()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .frame(maxWidth: .infinity)
                        .disabled(selectedEmotions.isEmpty)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(AppStyle.Colors.background(for: colorScheme))
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Gift Form View
struct GiftFormView: View {
    let onGiftAdded: (Gift) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var item = ""
    @State private var giver = "me" // "me" or "them"
    @State private var description = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                AppStyle.Colors.background(for: colorScheme)
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Text("ADD GIFT")
                        .font(AppStyle.Fonts.title)
                        .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 20) {
                        // Item input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("WHAT WAS THE GIFT?")
                                .font(AppStyle.Fonts.body)
                                .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                            
                            TextField("e.g., Flowers, Book, Coffee", text: $item)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Giver picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("WHO GAVE IT?")
                                .font(AppStyle.Fonts.body)
                                .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                            
                            HStack(spacing: 16) {
                                Button(action: {
                                    giver = "me"
                                }) {
                                    HStack {
                                        Image(systemName: giver == "me" ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(AppStyle.Colors.accent)
                                        Text("I gave it")
                                            .font(AppStyle.Fonts.body)
                                            .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                                    }
                                    .padding(.vertical, 12)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: {
                                    giver = "them"
                                }) {
                                    HStack {
                                        Image(systemName: giver == "them" ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(AppStyle.Colors.accent)
                                        Text("They gave it")
                                            .font(AppStyle.Fonts.body)
                                            .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                                    }
                                    .padding(.vertical, 12)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        // Description input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DESCRIPTION (OPTIONAL)")
                                .font(AppStyle.Fonts.body)
                                .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                            
                            TextField("Any special details?", text: $description)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    HStack(spacing: 16) {
                        Button("CANCEL") {
                            dismiss()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .frame(maxWidth: .infinity)
                        
                        Button("ADD GIFT") {
                            let gift = Gift(item: item, giver: giver, description: description)
                            onGiftAdded(gift)
                            dismiss()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .frame(maxWidth: .infinity)
                        .disabled(item.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Physical Touch Form View
struct PhysicalTouchFormView: View {
    let onTouchAdded: (PhysicalTouchMoment) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var touchType: PhysicalTouchType = .hug
    @State private var duration = "medium"
    @State private var context = ""
    
    private let durationOptions = ["brief", "medium", "long"]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppStyle.Colors.background(for: colorScheme)
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Text("ADD PHYSICAL TOUCH MOMENT")
                        .font(AppStyle.Fonts.title)
                        .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 24) {
                        // Touch type selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("TYPE OF TOUCH")
                                .font(AppStyle.Fonts.body)
                                .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                                ForEach(PhysicalTouchType.allCases, id: \.self) { type in
                                    Button(action: {
                                        touchType = type
                                    }) {
                                        VStack(spacing: 8) {
                                            Image(systemName: type.systemImage)
                                                .font(.system(size: 20))
                                                .foregroundColor(touchType == type ? AppStyle.Colors.accent : AppStyle.Colors.textSecondary(for: colorScheme))
                                            
                                            Text(type.rawValue)
                                                .font(AppStyle.Fonts.caption)
                                                .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                                                .multilineTextAlignment(.center)
                                                .lineLimit(2)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(12)
                                        .background(touchType == type ? AppStyle.Colors.accent.opacity(0.2) : AppStyle.Colors.surface(for: colorScheme))
                                        .overlay {
                                            Rectangle()
                                                .stroke(touchType == type ? AppStyle.Colors.accent : AppStyle.Colors.borderColor, lineWidth: touchType == type ? 2 : AppStyle.Layout.borderWidth)
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        
                        // Duration selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DURATION")
                                .font(AppStyle.Fonts.body)
                                .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                            
                            HStack(spacing: 12) {
                                ForEach(durationOptions, id: \.self) { option in
                                    Button(action: {
                                        duration = option
                                    }) {
                                        Text(option.capitalized)
                                            .font(AppStyle.Fonts.body)
                                            .foregroundColor(duration == option ? .white : AppStyle.Colors.textPrimary(for: colorScheme))
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(duration == option ? AppStyle.Colors.accent : AppStyle.Colors.surface(for: colorScheme))
                                            .overlay {
                                                Rectangle()
                                                    .stroke(AppStyle.Colors.borderColor, lineWidth: AppStyle.Layout.borderWidth)
                                            }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        
                        // Context input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CONTEXT (OPTIONAL)")
                                .font(AppStyle.Fonts.body)
                                .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                            
                            TextField("When did this happen?", text: $context)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    HStack(spacing: 16) {
                        Button("CANCEL") {
                            dismiss()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .frame(maxWidth: .infinity)
                        
                        Button("ADD MOMENT") {
                            let touch = PhysicalTouchMoment(touchType: touchType, duration: duration, context: context)
                            onTouchAdded(touch)
                            dismiss()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview("Emotion Picker") {
    EmotionPickerView { _ in }
}

#Preview("Gift Form") {
    GiftFormView { _ in }
}

#Preview("Touch Form") {
    PhysicalTouchFormView { _ in }
}