//
//  demo_it_linkApp.swift
//  demo_it_link
//
//  Created by DmitrySK on 27.05.2025.
//

import SwiftUI

@main
struct demo_it_linkApp: App {
    
    @AppStorage("selectedTheme") private var selectedTheme: ThemeMode = .system
    
    @StateObject private var appConfigManager = AppConfigManager()
    
    private var activeColorScheme: ColorScheme? {
            selectedTheme == .system ? nil : selectedTheme.colorScheme
        }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                appConfigManager.rootView
                    .tabItem {
                        Label("Галерея", systemImage: "photo.on.rectangle")
                    }
                    .tag(0)
                
                SettingsView(selectedTheme: $selectedTheme)
                    .tabItem {
                        Label("Настройки", systemImage: "gearshape")
                    }
                    .tag(1)
            }
            .preferredColorScheme(activeColorScheme)
            .animation(.easeInOut(duration: 0.3), value: selectedTheme)
        }
    }
}
