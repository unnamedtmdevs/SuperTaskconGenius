//
//  TaskModel.swift
//  Task conGenius
//
//  Created on Dec 18, 2025.
//

import Foundation
import SwiftUI

struct Task: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var description: String
    var isCompleted: Bool = false
    var priority: TaskPriority = .medium
    var category: TaskCategory = .personal
    var dueDate: Date?
    var createdAt: Date = Date()
    var completedAt: Date?
    var tags: [String] = []
    var automationRuleId: UUID?
    
    enum TaskPriority: String, Codable, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case urgent = "Urgent"
        
        var color: Color {
            switch self {
            case .low: return .gray
            case .medium: return .blue
            case .high: return .orange
            case .urgent: return Color(hex: "#E70104")
            }
        }
    }
    
    enum TaskCategory: String, Codable, CaseIterable {
        case personal = "Personal"
        case work = "Work"
        case health = "Health"
        case shopping = "Shopping"
        case finance = "Finance"
        case education = "Education"
        case other = "Other"
        
        var icon: String {
            switch self {
            case .personal: return "person.fill"
            case .work: return "briefcase.fill"
            case .health: return "heart.fill"
            case .shopping: return "cart.fill"
            case .finance: return "dollarsign.circle.fill"
            case .education: return "book.fill"
            case .other: return "folder.fill"
            }
        }
    }
    
    var isOverdue: Bool {
        guard let dueDate = dueDate, !isCompleted else { return false }
        return dueDate < Date()
    }
}

// Automation Rule Model
struct AutomationRule: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var isActive: Bool = true
    var triggerType: TriggerType
    var actionType: ActionType
    var conditions: [String: String] = [:]
    var createdAt: Date = Date()
    
    enum TriggerType: String, Codable, CaseIterable {
        case timeOfDay = "Time of Day"
        case dayOfWeek = "Day of Week"
        case taskCompletion = "Task Completion"
        case categoryBased = "Category Based"
        
        var description: String {
            switch self {
            case .timeOfDay: return "Trigger at specific time"
            case .dayOfWeek: return "Trigger on specific days"
            case .taskCompletion: return "Trigger when task is completed"
            case .categoryBased: return "Trigger based on category"
            }
        }
    }
    
    enum ActionType: String, Codable, CaseIterable {
        case createTask = "Create Task"
        case sendNotification = "Send Notification"
        case markComplete = "Mark Complete"
        case changeCategory = "Change Category"
        
        var icon: String {
            switch self {
            case .createTask: return "plus.circle.fill"
            case .sendNotification: return "bell.fill"
            case .markComplete: return "checkmark.circle.fill"
            case .changeCategory: return "folder.badge.plus"
            }
        }
    }
}

// Task Template Model
struct TaskTemplate: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var templateTitle: String
    var templateDescription: String
    var defaultPriority: Task.TaskPriority
    var defaultCategory: Task.TaskCategory
    var defaultTags: [String]
    var isRecurring: Bool = false
    var recurringInterval: RecurringInterval?
    
    enum RecurringInterval: String, Codable, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        case yearly = "Yearly"
    }
    
    func createTask() -> Task {
        return Task(
            title: templateTitle,
            description: templateDescription,
            priority: defaultPriority,
            category: defaultCategory,
            tags: defaultTags
        )
    }
}

// Productivity Statistics
struct ProductivityStats: Codable {
    var totalTasksCreated: Int = 0
    var totalTasksCompleted: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var completionByCategory: [String: Int] = [:]
    var completionByPriority: [String: Int] = [:]
    var averageCompletionTime: TimeInterval = 0
    
    var completionRate: Double {
        guard totalTasksCreated > 0 else { return 0 }
        return Double(totalTasksCompleted) / Double(totalTasksCreated)
    }
}

