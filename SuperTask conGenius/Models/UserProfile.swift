//
//  UserProfile.swift
//  Task conGenius
//
//  Created on Dec 18, 2025.
//

import Foundation

struct UserProfile: Codable {
    var userId: UUID = UUID()
    var username: String = "User"
    var email: String?
    var profileCreatedAt: Date = Date()
    var preferences: UserPreferences = UserPreferences()
    var stats: ProductivityStats = ProductivityStats()
    
    struct UserPreferences: Codable {
        var notificationsEnabled: Bool = true
        var defaultTaskPriority: Task.TaskPriority = .medium
        var defaultTaskCategory: Task.TaskCategory = .personal
        var theme: AppTheme = .system
        var soundEnabled: Bool = true
        var showCompletedTasks: Bool = true
        var sortOrder: SortOrder = .dueDate
        
        enum AppTheme: String, Codable, CaseIterable {
            case light = "Light"
            case dark = "Dark"
            case system = "System"
        }
        
        enum SortOrder: String, Codable, CaseIterable {
            case dueDate = "Due Date"
            case priority = "Priority"
            case category = "Category"
            case createdDate = "Created Date"
            case alphabetical = "Alphabetical"
        }
    }
}

