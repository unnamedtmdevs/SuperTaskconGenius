//
//  SettingsView.swift
//  Task conGenius
//
//  Created on Dec 18, 2025.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showingResetAlert = false
    @State private var showingStatsView = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                Form {
                    // Profile Section
                    Section(header: Text("Profile")) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.appPrimary)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                TextField("Username", text: Binding(
                                    get: { viewModel.userProfile.username },
                                    set: { viewModel.updateUsername($0) }
                                ))
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                
                                Text("Member since \(viewModel.userProfile.profileCreatedAt.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.system(size: 13))
                                    .foregroundColor(.appTextSecondary)
                            }
                        }
                        .padding(.vertical, 8)
                        
                        if let email = viewModel.userProfile.email {
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.appPrimary)
                                Text(email)
                            }
                        }
                    }
                    
                    // Preferences Section
                    Section(header: Text("Preferences")) {
                        Picker("Default Priority", selection: $viewModel.defaultPriority) {
                            ForEach(Task.TaskPriority.allCases, id: \.self) { priority in
                                Text(priority.rawValue).tag(priority)
                            }
                        }
                        .onChange(of: viewModel.defaultPriority) { _ in
                            viewModel.saveProfile()
                        }
                        
                        Picker("Default Category", selection: $viewModel.defaultCategory) {
                            ForEach(Task.TaskCategory.allCases, id: \.self) { category in
                                Label(category.rawValue, systemImage: category.icon).tag(category)
                            }
                        }
                        .onChange(of: viewModel.defaultCategory) { _ in
                            viewModel.saveProfile()
                        }
                        
                        Picker("Sort Order", selection: $viewModel.selectedSortOrder) {
                            ForEach(UserProfile.UserPreferences.SortOrder.allCases, id: \.self) { order in
                                Text(order.rawValue).tag(order)
                            }
                        }
                        .onChange(of: viewModel.selectedSortOrder) { _ in
                            viewModel.saveProfile()
                        }
                        
                        Picker("Theme", selection: $viewModel.selectedTheme) {
                            ForEach(UserProfile.UserPreferences.AppTheme.allCases, id: \.self) { theme in
                                Text(theme.rawValue).tag(theme)
                            }
                        }
                        .onChange(of: viewModel.selectedTheme) { _ in
                            viewModel.saveProfile()
                        }
                    }
                    
                    // Display Section
                    Section(header: Text("Display")) {
                        Toggle(isOn: $viewModel.showCompletedTasks) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.appSuccess)
                                Text("Show Completed Tasks")
                            }
                        }
                        .onChange(of: viewModel.showCompletedTasks) { _ in
                            viewModel.saveProfile()
                        }
                    }
                    
                    // Notifications Section
                    Section(header: Text("Notifications")) {
                        Toggle(isOn: $viewModel.notificationsEnabled) {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(.appPrimary)
                                Text("Enable Notifications")
                            }
                        }
                        .onChange(of: viewModel.notificationsEnabled) { newValue in
                            if newValue {
                                AutomationService.shared.requestNotificationPermission()
                            }
                            viewModel.saveProfile()
                        }
                        
                        Toggle(isOn: $viewModel.soundEnabled) {
                            HStack {
                                Image(systemName: "speaker.wave.2.fill")
                                    .foregroundColor(.appPrimary)
                                Text("Sound Effects")
                            }
                        }
                        .onChange(of: viewModel.soundEnabled) { _ in
                            viewModel.saveProfile()
                        }
                    }
                    
                    // Statistics Section
                    Section(header: Text("Statistics")) {
                        Button(action: {
                            showingStatsView = true
                        }) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(.appPrimary)
                                Text("View Productivity Stats")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14))
                            }
                        }
                        .foregroundColor(.appTextPrimary)
                        
                        StatisticRow(
                            icon: "list.bullet.circle.fill",
                            title: "Total Tasks Created",
                            value: "\(TaskService.shared.tasks.count)",
                            color: .blue
                        )
                        
                        StatisticRow(
                            icon: "checkmark.circle.fill",
                            title: "Tasks Completed",
                            value: "\(TaskService.shared.tasks.filter { $0.isCompleted }.count)",
                            color: .green
                        )
                        
                        let completionRate = TaskService.shared.calculateStats().completionRate
                        StatisticRow(
                            icon: "percent",
                            title: "Completion Rate",
                            value: String(format: "%.0f%%", completionRate * 100),
                            color: .orange
                        )
                    }
                    
                    // Data Management Section
                    Section(header: Text("Data")) {
                        Button(action: {
                            let data = viewModel.exportData()
                            // In a real app, you would share this data
                            print("Exported data: \(data)")
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.blue)
                                Text("Export Data")
                            }
                        }
                        
                        Button(action: {
                            TaskService.shared.deleteCompletedTasks()
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(.orange)
                                Text("Clear Completed Tasks")
                            }
                        }
                        
                        Button(action: {
                            showingResetAlert = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                    .foregroundColor(.red)
                                Text("Reset Application")
                            }
                        }
                    }
                    
                    // About Section
                    Section(header: Text("About")) {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.appTextSecondary)
                        }
                        
                        HStack {
                            Text("Build")
                            Spacer()
                            Text("2025.12.18")
                                .foregroundColor(.appTextSecondary)
                        }
                        
                        Button(action: {
                            hasCompletedOnboarding = false
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.appPrimary)
                                Text("Show Onboarding Again")
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Reset Application?", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    viewModel.resetApp()
                    hasCompletedOnboarding = false
                }
            } message: {
                Text("This will delete all your tasks, templates, and automation rules. This action cannot be undone.")
            }
            .sheet(isPresented: $showingStatsView) {
                ProductivityStatsView(stats: viewModel.getStatistics())
            }
        }
    }
}

struct StatisticRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 15))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.appTextPrimary)
        }
    }
}

struct ProductivityStatsView: View {
    let stats: ProductivityStats
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Summary Cards
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                StatsCard(
                                    title: "Total Tasks",
                                    value: "\(stats.totalTasksCreated)",
                                    icon: "list.bullet",
                                    color: .blue
                                )
                                
                                StatsCard(
                                    title: "Completed",
                                    value: "\(stats.totalTasksCompleted)",
                                    icon: "checkmark.circle.fill",
                                    color: .green
                                )
                            }
                            
                            HStack(spacing: 16) {
                                StatsCard(
                                    title: "Current Streak",
                                    value: "\(stats.currentStreak)",
                                    icon: "flame.fill",
                                    color: .orange
                                )
                                
                                StatsCard(
                                    title: "Best Streak",
                                    value: "\(stats.longestStreak)",
                                    icon: "star.fill",
                                    color: .yellow
                                )
                            }
                            
                            // Completion Rate
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Completion Rate")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.appTextPrimary)
                                
                                HStack {
                                    Text(String(format: "%.0f%%", stats.completionRate * 100))
                                        .font(.system(size: 36, weight: .bold, design: .rounded))
                                        .foregroundColor(.appPrimary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .font(.system(size: 40))
                                        .foregroundColor(.appPrimary.opacity(0.3))
                                }
                                
                                ProgressView(value: stats.completionRate)
                                    .tint(.appPrimary)
                            }
                            .padding()
                            .cardStyle()
                        }
                        
                        // Completion by Category
                        if !stats.completionByCategory.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Tasks by Category")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.appTextPrimary)
                                
                                ForEach(Array(stats.completionByCategory.keys.sorted()), id: \.self) { categoryName in
                                    if let count = stats.completionByCategory[categoryName],
                                       let category = Task.TaskCategory(rawValue: categoryName) {
                                        HStack {
                                            Image(systemName: category.icon)
                                                .foregroundColor(.appPrimary)
                                                .frame(width: 24)
                                            
                                            Text(categoryName)
                                                .font(.system(size: 15))
                                            
                                            Spacer()
                                            
                                            Text("\(count)")
                                                .font(.system(size: 15, weight: .bold))
                                                .foregroundColor(.appPrimary)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .cardStyle()
                        }
                        
                        // Completion by Priority
                        if !stats.completionByPriority.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Tasks by Priority")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.appTextPrimary)
                                
                                ForEach(Array(stats.completionByPriority.keys.sorted()), id: \.self) { priorityName in
                                    if let count = stats.completionByPriority[priorityName],
                                       let priority = Task.TaskPriority(rawValue: priorityName) {
                                        HStack {
                                            Circle()
                                                .fill(priority.color)
                                                .frame(width: 12, height: 12)
                                            
                                            Text(priorityName)
                                                .font(.system(size: 15))
                                            
                                            Spacer()
                                            
                                            Text("\(count)")
                                                .font(.system(size: 15, weight: .bold))
                                                .foregroundColor(priority.color)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .cardStyle()
                        }
                        
                        // Average Completion Time
                        if stats.averageCompletionTime > 0 {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Average Completion Time")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.appTextPrimary)
                                
                                let hours = Int(stats.averageCompletionTime) / 3600
                                let minutes = (Int(stats.averageCompletionTime) % 3600) / 60
                                
                                HStack {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.appPrimary)
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing) {
                                        if hours > 0 {
                                            Text("\(hours)h \(minutes)m")
                                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                                .foregroundColor(.appTextPrimary)
                                        } else {
                                            Text("\(minutes)m")
                                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                                .foregroundColor(.appTextPrimary)
                                        }
                                        
                                        Text("on average")
                                            .font(.system(size: 14))
                                            .foregroundColor(.appTextSecondary)
                                    }
                                }
                            }
                            .padding()
                            .cardStyle()
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Productivity Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
}

struct StatsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.appTextPrimary)
            
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .cardStyle()
    }
}

#Preview {
    SettingsView()
}

