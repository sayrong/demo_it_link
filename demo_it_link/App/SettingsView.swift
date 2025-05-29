//
//  SettingsView.swift
//  demo_it_link
//
//  Created by DmitrySK on 29.05.2025.
//

import SwiftUI

struct SettingsView: View {
    @Binding var selectedTheme: ThemeMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Тема оформления")) {
                    Picker("Выберите тему", selection: $selectedTheme) {
                        ForEach(ThemeMode.allCases, id: \.self) { theme in
                            HStack {
                                Image(systemName: theme.icon)
                                Text(theme.title)
                            }
                        }
                    }
                    .pickerStyle(.inline)
                }
            }
            .navigationTitle("Настройки")
        }
    }
}

#Preview {
    SettingsView(selectedTheme: .constant(.dark))
}
