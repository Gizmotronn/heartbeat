//
//  AnalysisLoadingView.swift
//  Heartbeat
//
//  Created by Liam Arbuckle on 8/1/2026.
//

import SwiftUI

struct AnalysisLoadingView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var currentStep = 0
    @State private var dots = ""
    
    private let analysisSteps = [
        "Analyzing relationship patterns",
        "Processing date frequency data", 
        "Examining location preferences",
        "Evaluating emotional patterns",
        "Generating personalized insights"
    ]
    
    var body: some View {
        VStack(spacing: 32) {
            // Apple Intelligence animation
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(AppStyle.Colors.accent.opacity(0.2), lineWidth: 3)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(AppStyle.Colors.accent, lineWidth: 3)
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                        .rotationEffect(.degrees(Double(currentStep) * 72))
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: false), value: currentStep)
                    
                    Text("🧠")
                        .font(.system(size: 32))
                }
                
                Text("APPLE INTELLIGENCE")
                    .font(AppStyle.Fonts.title)
                    .foregroundColor(AppStyle.Colors.accent)
            }
            
            // Analysis steps
            VStack(spacing: 20) {
                ForEach(0..<analysisSteps.count, id: \.self) { index in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(index <= currentStep ? AppStyle.Colors.accent : AppStyle.Colors.textSecondary(for: colorScheme).opacity(0.3))
                            .frame(width: 8, height: 8)
                        
                        Text(analysisSteps[index] + (index == currentStep ? dots : ""))
                            .font(AppStyle.Fonts.body)
                            .foregroundColor(index <= currentStep ? AppStyle.Colors.textPrimary(for: colorScheme) : AppStyle.Colors.textSecondary(for: colorScheme))
                        
                        Spacer()
                        
                        if index == currentStep {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(AppStyle.Colors.accent)
                        } else if index < currentStep {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppStyle.Colors.accent)
                                .font(.system(size: 16, weight: .medium))
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
            }
            .padding(.horizontal, 24)
            
            Text("Analyzing your relationship data to provide personalized insights...")
                .font(AppStyle.Fonts.caption)
                .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.vertical, 40)
        .onAppear {
            startAnalysisAnimation()
        }
    }
    
    private func startAnalysisAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { timer in
            withAnimation(.easeInOut(duration: 0.3)) {
                if currentStep < analysisSteps.count - 1 {
                    currentStep += 1
                } else {
                    timer.invalidate()
                }
            }
        }
        
        // Dots animation for current step
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            dots = dots.count < 3 ? dots + "." : ""
        }
    }
}

struct AnalysisErrorView: View {
    let error: String
    let onRetry: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Text("⚠️")
                    .font(.system(size: 60))
                
                Text("ANALYSIS UNAVAILABLE")
                    .font(AppStyle.Fonts.heading)
                    .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                
                Text(error)
                    .font(AppStyle.Fonts.body)
                    .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button("TRY AGAIN") {
                onRetry()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.vertical, 40)
    }
}

#Preview {
    VStack {
        AnalysisLoadingView()
        Spacer()
        AnalysisErrorView(error: "Unable to connect to analysis service.") {
            print("Retry tapped")
        }
    }
    .background(AppStyle.Colors.background(for: .light))
}