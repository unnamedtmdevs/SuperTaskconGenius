//
//  SettingsViewModel.swift
//  Task conGenius
//
//  Created on Dec 18, 2025.
//

import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var userProfile: UserProfile = UserProfile()
    @Published var showCompletedTasks: Bool = true
    @Published var notificationsEnabled: Bool = true
    @Published var soundEnabled: Bool = true
    @Published var selectedTheme: UserProfile.UserPreferences.AppTheme = .system
    @Published var selectedSortOrder: UserProfile.UserPreferences.SortOrder = .dueDate
    @Published var defaultPriority: Task.TaskPriority = .medium
    @Published var defaultCategory: Task.TaskCategory = .personal
    
    private let userProfileKey = "user_profile"
    
    init() {
        loadProfile()
    }
    
    func loadProfile() {
        if let data = UserDefaults.standard.data(forKey: userProfileKey),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            userProfile = profile
            
            // Update published properties
            showCompletedTasks = profile.preferences.showCompletedTasks
            notificationsEnabled = profile.preferences.notificationsEnabled
            soundEnabled = profile.preferences.soundEnabled
            selectedTheme = profile.preferences.theme
            selectedSortOrder = profile.preferences.sortOrder
            defaultPriority = profile.preferences.defaultTaskPriority
            defaultCategory = profile.preferences.defaultTaskCategory
        }
    }
    
    func saveProfile() {
        // Update profile from published properties
        userProfile.preferences.showCompletedTasks = showCompletedTasks
        userProfile.preferences.notificationsEnabled = notificationsEnabled
        userProfile.preferences.soundEnabled = soundEnabled
        userProfile.preferences.theme = selectedTheme
        userProfile.preferences.sortOrder = selectedSortOrder
        userProfile.preferences.defaultTaskPriority = defaultPriority
        userProfile.preferences.defaultTaskCategory = defaultCategory
        
        // Save to UserDefaults
        if let encoded = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encoded, forKey: userProfileKey)
        }
    }
    
    func updateUsername(_ newName: String) {
        userProfile.username = newName
        saveProfile()
    }
    
    func updateEmail(_ newEmail: String) {
        userProfile.email = newEmail
        saveProfile()
    }
    
    func resetApp() {
        // Clear all data
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        
        // Reset to defaults
        userProfile = UserProfile()
        loadProfile()
    }
    
    func exportData() -> String {
        let tasks = TaskService.shared.tasks
        let templates = TaskService.shared.templates
        let rules = AutomationService.shared.automationRules
        
        let exportData: [String: Any] = [
            "profile": try? JSONEncoder().encode(userProfile),
            "tasks": try? JSONEncoder().encode(tasks),
            "templates": try? JSONEncoder().encode(templates),
            "rules": try? JSONEncoder().encode(rules),
            "exportDate": Date().description
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        
        return ""
    }
    
    func getStatistics() -> ProductivityStats {
        var stats = TaskService.shared.calculateStats()
        stats.currentStreak = userProfile.stats.currentStreak
        stats.longestStreak = userProfile.stats.longestStreak
        return stats
    }
    
    func updateStatistics() {
        userProfile.stats = TaskService.shared.calculateStats()
        saveProfile()
    }
}

