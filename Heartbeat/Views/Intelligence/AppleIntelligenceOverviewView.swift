//
//  AppleIntelligenceOverviewView.swift
//  Heartbeat
//
//  Created by Liam Arbuckle on 8/1/2026.
//

import SwiftUI

struct AppleIntelligenceOverviewView: View {
    let person: DatePerson
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var insights: [RelationshipInsight] = []
    @State private var isAnalyzing = true
    @State private var analysisError: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                AppStyle.Colors.background(for: colorScheme)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        IntelligenceHeaderView()
                        
                        // Analysis Content
                        if isAnalyzing {
                            AnalysisLoadingView()
                        } else if let error = analysisError {
                            AnalysisErrorView(error: error) {
                                Task {
                                    await performAnalysis()
                                }
                            }
                        } else {
                            // Insights
                            LazyVStack(spacing: 16) {
                                ForEach(insights, id: \.title) { insight in
                                    InsightCard(insight: insight)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("DONE") {
                        dismiss()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            }
        }
        .task {
            await performAnalysis()
        }
    }
    
    private func performAnalysis() async {
        isAnalyzing = true
        analysisError = nil
        
        do {
            let analyzer = RelationshipAnalyzer()
            let generatedInsights = await analyzer.analyzeRelationship(person: person)
            
            await MainActor.run {
                self.insights = generatedInsights
                self.isAnalyzing = false
            }
        } catch {
            await MainActor.run {
                self.analysisError = "Unable to complete analysis. Please try again."
                self.isAnalyzing = false
            }
        }
    }
}