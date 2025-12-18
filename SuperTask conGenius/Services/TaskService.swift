//
//  TaskService.swift
//  Task conGenius
//
//  Created on Dec 18, 2025.
//

import Foundation
import Combine

class TaskService: ObservableObject {
    static let shared = TaskService()
    
    @Published var tasks: [Task] = []
    @Published var templates: [TaskTemplate] = []
    
    private let tasksKey = "saved_tasks"
    private let templatesKey = "saved_templates"
    
    private init() {
        loadTasks()
        loadTemplates()
    }
    
    // MARK: - Task Operations
    
    func addTask(_ task: Task) {
        tasks.append(task)
        saveTasks()
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    func toggleTaskCompletion(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            tasks[index].completedAt = tasks[index].isCompleted ? Date() : nil
            saveTasks()
        }
    }
    
    func deleteCompletedTasks() {
        tasks.removeAll { $0.isCompleted }
        saveTasks()
    }
    
    // MARK: - Template Operations
    
    func addTemplate(_ template: TaskTemplate) {
        templates.append(template)
        saveTemplates()
    }
    
    func deleteTemplate(_ template: TaskTemplate) {
        templates.removeAll { $0.id == template.id }
        saveTemplates()
    }
    
    func createTaskFromTemplate(_ template: TaskTemplate) -> Task {
        let task = template.createTask()
        addTask(task)
        return task
    }
    
    // MARK: - Filtering and Sorting
    
    func filteredTasks(category: Task.TaskCategory? = nil, showCompleted: Bool = true) -> [Task] {
        var filtered = tasks
        
        if let category = category {
            filtered = filtered.filter { $0.category == category }
        }
        
        if !showCompleted {
            filtered = filtered.filter { !$0.isCompleted }
        }
        
        return filtered
    }
    
    func sortedTasks(_ tasks: [Task], by sortOrder: UserProfile.UserPreferences.SortOrder) -> [Task] {
        switch sortOrder {
        case .dueDate:
            return tasks.sorted { task1, task2 in
                guard let date1 = task1.dueDate else { return false }
                guard let date2 = task2.dueDate else { return true }
                return date1 < date2
            }
        case .priority:
            let priorityOrder: [Task.TaskPriority] = [.urgent, .high, .medium, .low]
            return tasks.sorted { task1, task2 in
                let index1 = priorityOrder.firstIndex(of: task1.priority) ?? 999
                let index2 = priorityOrder.firstIndex(of: task2.priority) ?? 999
                return index1 < index2
            }
        case .category:
            return tasks.sorted { $0.category.rawValue < $1.category.rawValue }
        case .createdDate:
            return tasks.sorted { $0.createdAt > $1.createdAt }
        case .alphabetical:
            return tasks.sorted { $0.title.lowercased() < $1.title.lowercased() }
        }
    }
    
    // MARK: - Statistics
    
    func calculateStats() -> ProductivityStats {
        var stats = ProductivityStats()
        
        stats.totalTasksCreated = tasks.count
        stats.totalTasksCompleted = tasks.filter { $0.isCompleted }.count
        
        // Calculate completion by category
        for category in Task.TaskCategory.allCases {
            let completed = tasks.filter { $0.category == category && $0.isCompleted }.count
            if completed > 0 {
                stats.completionByCategory[category.rawValue] = completed
            }
        }
        
        // Calculate completion by priority
        for priority in Task.TaskPriority.allCases {
            let completed = tasks.filter { $0.priority == priority && $0.isCompleted }.count
            if completed > 0 {
                stats.completionByPriority[priority.rawValue] = completed
            }
        }
        
        // Calculate average completion time
        let completedTasks = tasks.filter { $0.isCompleted && $0.completedAt != nil }
        if !completedTasks.isEmpty {
            let totalTime = completedTasks.reduce(0.0) { sum, task in
                guard let completedAt = task.completedAt else { return sum }
                return sum + completedAt.timeIntervalSince(task.createdAt)
            }
            stats.averageCompletionTime = totalTime / Double(completedTasks.count)
        }
        
        // Calculate streak
        stats.currentStreak = calculateCurrentStreak()
        stats.longestStreak = calculateLongestStreak()
        
        return stats
    }
    
    private func calculateCurrentStreak() -> Int {
        let completedTasks = tasks.filter { $0.isCompleted }.sorted { 
            ($0.completedAt ?? Date()) > ($1.completedAt ?? Date()) 
        }
        
        guard !completedTasks.isEmpty else { return 0 }
        
        var streak = 0
        var currentDate = Calendar.current.startOfDay(for: Date())
        
        for task in completedTasks {
            guard let completedAt = task.completedAt else { continue }
            let taskDate = Calendar.current.startOfDay(for: completedAt)
            
            if taskDate == currentDate || taskDate == Calendar.current.date(byAdding: .day, value: -1, to: currentDate) {
                streak += 1
                currentDate = taskDate
            } else {
                break
            }
        }
        
        return streak
    }
    
    private func calculateLongestStreak() -> Int {
        let completedTasks = tasks.filter { $0.isCompleted }.sorted { 
            ($0.completedAt ?? Date()) < ($1.completedAt ?? Date()) 
        }
        
        guard !completedTasks.isEmpty else { return 0 }
        
        var longestStreak = 0
        var currentStreak = 1
        var previousDate: Date?
        
        for task in completedTasks {
            guard let completedAt = task.completedAt else { continue }
            let taskDate = Calendar.current.startOfDay(for: completedAt)
            
            if let prevDate = previousDate {
                let dayDifference = Calendar.current.dateComponents([.day], from: prevDate, to: taskDate).day ?? 0
                if dayDifference == 1 {
                    currentStreak += 1
                } else if dayDifference > 1 {
                    longestStreak = max(longestStreak, currentStreak)
                    currentStreak = 1
                }
            }
            
            previousDate = taskDate
        }
        
        return max(longestStreak, currentStreak)
    }
    
    // MARK: - Persistence
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
    }
    
    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: tasksKey),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        }
    }
    
    private func saveTemplates() {
        if let encoded = try? JSONEncoder().encode(templates) {
            UserDefaults.standard.set(encoded, forKey: templatesKey)
        }
    }
    
    private func loadTemplates() {
        if let data = UserDefaults.standard.data(forKey: templatesKey),
           let decoded = try? JSONDecoder().decode([TaskTemplate].self, from: data) {
            templates = decoded
        } else {
            // Add default templates
            createDefaultTemplates()
        }
    }
    
    private func createDefaultTemplates() {
        templates = [
            TaskTemplate(
                name: "Morning Routine",
                templateTitle: "Complete Morning Routine",
                templateDescription: "Exercise, breakfast, and planning",
                defaultPriority: .high,
                defaultCategory: .health,
                defaultTags: ["routine", "morning"],
                isRecurring: true,
                recurringInterval: .daily
            ),
            TaskTemplate(
                name: "Weekly Review",
                templateTitle: "Weekly Review & Planning",
                templateDescription: "Review completed tasks and plan for next week",
                defaultPriority: .medium,
                defaultCategory: .personal,
                defaultTags: ["planning", "review"],
                isRecurring: true,
                recurringInterval: .weekly
            ),
            TaskTemplate(
                name: "Shopping List",
                templateTitle: "Grocery Shopping",
                templateDescription: "Buy weekly groceries",
                defaultPriority: .medium,
                defaultCategory: .shopping,
                defaultTags: ["groceries", "shopping"],
                isRecurring: true,
                recurringInterval: .weekly
            )
        ]
        saveTemplates()
    }
}

