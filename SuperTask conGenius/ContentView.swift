//
//  ContentView.swift
//  Task conGenius
//
//  Created on Dec 18, 2025.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var selectedTab = 0
    
    var body: some View {
        if !hasCompletedOnboarding {
            OnboardingView()
        } else {
            TabView(selection: $selectedTab) {
                TaskListView()
                    .tabItem {
                        Label("Tasks", systemImage: "list.bullet")
                    }
                    .tag(0)
                
                AutomationView()
                    .tabItem {
                        Label("Automation", systemImage: "gearshape.2.fill")
                    }
                    .tag(1)
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(2)
            }
            .accentColor(.appPrimary)
        }
    }
}

#Preview {
    ContentView()
}
