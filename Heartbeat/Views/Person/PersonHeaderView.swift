//
//  PersonHeaderView.swift
//  Heartbeat
//
//  Created by Liam Arbuckle on 8/1/2026.
//

import SwiftUI
import Combine

struct PersonHeaderView: View {
    let person: DatePerson
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            Group {
                if let profileImage = person.profileImage {
                    profileImage
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(AppStyle.Colors.textSecondary(for: colorScheme).opacity(0.3))
                        .overlay {
                            Image(systemName: "person.fill")
                                .font(.system(size: 48, weight: .black))
                                .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                        }
                }
            }
            .frame(width: 140, height: 140)
            .overlay {
                Rectangle()
                    .stroke(AppStyle.Colors.borderColor, lineWidth: AppStyle.Layout.borderWidth)
            }
            .shadow(
                color: AppStyle.Colors.shadowColor,
                radius: 0,
                x: AppStyle.Layout.shadowOffset.width,
                y: AppStyle.Layout.shadowOffset.height
            )
            
            VStack(spacing: 8) {
                Text(person.name)
                    .font(AppStyle.Fonts.heading)
                    .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                
                Text("FIRST MET: \(person.meetingDate.formatted(date: .abbreviated, time: .omitted).uppercased())")
                    .font(AppStyle.Fonts.caption)
                    .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
            }
            .frame(maxWidth: .infinity)
            
            // Phone number and iMessage button
            if !person.phoneNumber.isEmpty {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("PHONE")
                            .font(AppStyle.Fonts.caption)
                            .foregroundColor(AppStyle.Colors.textSecondary(for: colorScheme))
                        
                        Text(person.phoneNumber)
                            .font(AppStyle.Fonts.body)
                            .foregroundColor(AppStyle.Colors.textPrimary(for: colorScheme))
                    }
                    
                    Spacer()
                    
                    Button {
                        openIMessage(phoneNumber: person.phoneNumber)
                    } label: {
                        Image(systemName: "message.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.green)
                            .overlay {
                                Rectangle()
                                    .stroke(AppStyle.Colors.borderColor, lineWidth: AppStyle.Layout.borderWidth)
                            }
                    }
                }
                .padding(12)
                .background(AppStyle.Colors.surface(for: colorScheme))
                .overlay {
                    Rectangle()
                        .stroke(AppStyle.Colors.borderColor, lineWidth: AppStyle.Layout.borderWidth)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
    
    private func openIMessage(phoneNumber: String) {
        let cleanedPhoneNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if let url = URL(string: "sms:\(cleanedPhoneNumber)") {
            UIApplication.shared.open(url)
        }
    }
}