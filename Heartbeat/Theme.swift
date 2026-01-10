//
//  Theme.swift
//  Heartbeat
//
//  Centralized style and color tokens for the app.
//

import SwiftUI

// App-wide style tokens - NEOBRUTALIST THEME
enum AppStyle {
    enum Colors {
        // Provide simple light/dark aware tokens
        static func background(for scheme: ColorScheme) -> Color {
            scheme == .dark ? Color(hex: "#0B1220") : Color(hex: "#F7F9FC")
        }

        static func surface(for scheme: ColorScheme) -> Color {
            scheme == .dark ? Color(hex: "#0F1724") : Color(hex: "#FFFFFF")
        }

        static func textPrimary(for scheme: ColorScheme) -> Color {
            scheme == .dark ? Color(hex: "#E6EEF6") : Color(hex: "#0B1B2B")
        }

        static func textSecondary(for scheme: ColorScheme) -> Color {
            scheme == .dark ? Color(hex: "#9FB4C9") : Color(hex: "#55707F")
        }

        static var accent: Color { Color(hex: "#FF6B6B") }
        static var accentMuted: Color { Color(hex: "#FFB6B6") }
        
        // Neobrutalist specific colors
        static var shadowColor: Color { Color.black.opacity(0.2) }
        static var borderColor: Color { Color.black }
    }

    enum Fonts {
        // Bold, chunky neobrutalist typography
        static var title: Font { .system(size: 22, weight: .black, design: .default) }
        static var body: Font { .system(size: 16, weight: .bold, design: .default) }
        static var caption: Font { .system(size: 14, weight: .semibold, design: .default) }
        static var heading: Font { .system(size: 28, weight: .black, design: .default) }
    }
    
    enum Layout {
        static let cornerRadius: CGFloat = 0 // Sharp corners
        static let borderWidth: CGFloat = 3
        static let shadowOffset: CGSize = CGSize(width: 6, height: 6)
        static let buttonPadding: EdgeInsets = EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)
        static let cardPadding: EdgeInsets = EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
    }

    // Helpers
    static let HEADER_HEIGHT: CGFloat = 44
}

// Lightweight initializer for Color from hex string (#RRGGBB or RRGGBB, supports optional alpha)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "# "))
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b, a: UInt64
        switch hex.count {
        case 6: // RRGGBB
            (r, g, b, a) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF, 0xFF)
        case 8: // RRGGBBAA
            (r, g, b, a) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (0, 0, 0, 0xFF)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0,
            opacity: Double(a) / 255.0
        )
    }
}

struct NeobrutalistCard: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let backgroundColor: Color?
    
    init(backgroundColor: Color? = nil) {
        self.backgroundColor = backgroundColor
    }
    
    func body(content: Content) -> some View {
        content
            .padding(AppStyle.Layout.cardPadding)
            .background(backgroundColor ?? AppStyle.Colors.surface(for: colorScheme))
            .overlay {
                Rectangle()
                    .stroke(AppStyle.Colors.borderColor, lineWidth: AppStyle.Layout.borderWidth)
            }
    }
}

struct NeobrutalistButton: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let backgroundColor: Color
    let foregroundColor: Color
    let isPressed: Bool
    
    func body(content: Content) -> some View {
        content
            .font(AppStyle.Fonts.body)
            .foregroundColor(foregroundColor)
            .padding(AppStyle.Layout.buttonPadding)
            .background(backgroundColor)
            .overlay {
                Rectangle()
                    .stroke(AppStyle.Colors.borderColor, lineWidth: AppStyle.Layout.borderWidth)
            }
            .offset(
                x: isPressed ? 4 : 0,
                y: isPressed ? 4 : 0
            )
    }
}

extension View {
    func neobrutalistCard(backgroundColor: Color? = nil) -> some View {
        modifier(NeobrutalistCard(backgroundColor: backgroundColor))
    }
    
    func neobrutalistButton(
        backgroundColor: Color,
        foregroundColor: Color,
        isPressed: Bool = false
    ) -> some View {
        modifier(NeobrutalistButton(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            isPressed: isPressed
        ))
    }
}
