//
//  Color+Extensions.swift
//  Task conGenius
//
//  Created on Dec 18, 2025.
//

import SwiftUI

extension Color {
    // App Color Scheme
    static let appBackground = Color(hex: "#F0F1F3")
    static let appPrimary = Color(hex: "#E70104")
    static let appSecondary = Color(hex: "#FF3B3F")
    
    // Additional UI Colors
    static let appCardBackground = Color.white
    static let appTextPrimary = Color.black
    static let appTextSecondary = Color.gray
    static let appSuccess = Color.green
    static let appWarning = Color.orange
    static let appError = Color(hex: "#E70104")
    
    // Gradient Colors
    static let gradientStart = Color(hex: "#E70104")
    static let gradientEnd = Color(hex: "#FF3B3F")
    
    // Initialize Color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Custom View Modifiers
extension View {
    func cardStyle() -> some View {
        self
            .background(Color.appCardBackground)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    func primaryButtonStyle() -> some View {
        self
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.gradientStart, Color.gradientEnd]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color.appPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    func secondaryButtonStyle() -> some View {
        self
            .font(.system(size: 17, weight: .medium, design: .rounded))
            .foregroundColor(.appPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.appCardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.appPrimary, lineWidth: 2)
            )
    }
}

