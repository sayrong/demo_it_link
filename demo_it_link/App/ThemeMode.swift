//
//  ThemeMode.swift
//  demo_it_link
//
//  Created by DmitrySK on 29.05.2025.
//

import SwiftUI

enum ThemeMode: String, CaseIterable {
    case system
    case light
    case dark
    
    var icon: String {
        switch self {
        case .system: return "gearshape.2"
        case .light: return "sun.max"
        case .dark: return "moon"
        }
    }
    
    var title: String {
        switch self {
        case .system: return "Системная"
        case .light: return "Светлая"
        case .dark: return "Темная"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
